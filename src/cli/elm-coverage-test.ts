import { readFile, writeFile, mkdir, rm, readdir, stat } from 'fs/promises';
import { join, dirname, basename, resolve } from 'path';
import { fileURLToPath } from 'url';
import { execFile } from 'child_process';
import { promisify } from 'util';
import yargs from 'yargs';
import { hideBin } from 'yargs/helpers';
import { instrument, report, type CoverageMetadataMap, type CoverageData, type ReportFormat, type Report, type ModuleMetadata } from '../library.js';
import { ensureElmProjectRoot } from './helpers.js';

const execFileAsync = promisify(execFile);

function getBinDirectory(): string {
    // Absolute path to bin directory, used as --compiler flag later.
    const currentFile = fileURLToPath(import.meta.url);
    const currentDir = dirname(currentFile);
    return resolve(currentDir, '../../bin');
}

interface CliArgs {
    runner: string;
    coverageFormat: ReportFormat;
    coverageOutput?: string;
    forwardedArgs: string[];
}

function parseArgs(): CliArgs {
    const argv = yargs(hideBin(process.argv))
        .option('runner', {
            type: 'string',
            default: 'elm-test',
            description: 'Path to the test runner binary (defaults to elm-test)',
        })
        .option('coverage-format', {
            type: 'string',
            choices: ['lcov', 'html', 'csv', 'plaintext', 'stdout'],
            default: 'stdout',
            description: 'Format for the coverage report',
        })
        .option('coverage-output', {
            type: 'string',
            description: 'Path to the coverage output file (or folder for HTML format). Ignored when format is stdout.',
        })
        .strict(false) // Allow unknown options to be forwarded
        .parseSync();

    const runner = argv.runner as string;
    const coverageFormat = argv['coverage-format'] as ReportFormat;
    const coverageOutput = argv['coverage-output'] as string | undefined;

    const forwardedArgs: string[] = [];
    const knownFlags = new Set(['--runner', '--coverage-format', '--coverage-output']);
    const originalArgs = process.argv.slice(2);
    
    let skipNext = false;
    originalArgs.forEach((arg, i) => {
        if (skipNext) {
            skipNext = false;
            return;
        }
        if (typeof arg !== 'string') {
            // Should not happen, but skip non-string just in case
            return;
        }
        // Check if it's a known flag (with or without =value)
        if (knownFlags.has(arg)) {
            // Skip the value if it's a separate argument
            const nextArg = originalArgs[i + 1];
            if (i + 1 < originalArgs.length && typeof nextArg === 'string' && !nextArg.startsWith('-')) {
                skipNext = true;
            }
        } else if (
            typeof arg === 'string' &&
            (arg.startsWith('--runner=') ||
            arg.startsWith('--coverage-format=') ||
            arg.startsWith('--coverage-output='))
        ) {
            // Skip flags with =value syntax
            return;
        } else {
            forwardedArgs.push(arg);
        }
    });

    const result: CliArgs = {
        runner,
        coverageFormat,
        forwardedArgs,
    };
    if (coverageOutput !== undefined) {
        result.coverageOutput = coverageOutput;
    }
    return result;
}

async function findElmFiles(dir: string): Promise<string[]> {
    const files: string[] = [];
    
    async function walk(currentDir: string) {
        const entries = await readdir(currentDir);
        
        for (const entry of entries) {
            // Skip common directories
            if (entry === 'elm-stuff' || entry === 'node_modules' || entry === '.git') {
                continue;
            }
            
            const fullPath = join(currentDir, entry);
            const stats = await stat(fullPath);
            
            if (stats.isDirectory()) {
                await walk(fullPath);
            } else if (entry.endsWith('.elm')) {
                files.push(fullPath);
            }
        }
    }
    
    await walk(dir);
    return files;
}

async function instrumentFiles(elmFiles: string[]): Promise<{ 
    coverageMetadata: CoverageMetadataMap, 
    instrumentedFiles: Map<string, string>,
    moduleMetadata: ModuleMetadata
}> {
    const coverageMetadatas: CoverageMetadataMap[] = [];
    const instrumentedFiles = new Map<string, string>();
    const moduleMetadata: ModuleMetadata = new Map<string, number>();
    
    for (const filePath of elmFiles) {
        const sourceCode = await readFile(filePath, 'utf-8');
        const output = await instrument(sourceCode);
        
        if ('error' in output) {
            console.error(`Error instrumenting ${filePath}: ${output.error}`);
            process.exit(1);
        }
        
        instrumentedFiles.set(filePath, output.instrumentedElmSourceCode);
        coverageMetadatas.push(output.coverageMetadata);
        moduleMetadata.set(filePath, output.contentHash);
    }

    const coverageMetadata: CoverageMetadataMap = new Map(coverageMetadatas.flatMap(m => [...m]));
    
    return { coverageMetadata, instrumentedFiles, moduleMetadata };
}

async function createTempProject(
    tempDir: string,
    instrumentedFiles: Map<string, string>,
    originalElmJson: string,
    originalSourceDirs: string[]
): Promise<void> {
    // Copy elm.json
    await writeFile(join(tempDir, 'elm.json'), originalElmJson);
    
    // Create source directories and copy instrumented files
    for (const [originalPath, instrumentedCode] of instrumentedFiles.entries()) {
        // Find which source directory this file belongs to
        let relativePath: string | null = null;
        const normalizedOriginalPath = resolve(originalPath).replace(/\\/g, '/');
        
        for (const sourceDir of originalSourceDirs) {
            const normalizedSourceDir = resolve(sourceDir).replace(/\\/g, '/');
            if (normalizedOriginalPath.startsWith(normalizedSourceDir + '/')) {
                relativePath = normalizedOriginalPath.slice(normalizedSourceDir.length + 1);
                break;
            }
        }
        
        if (!relativePath) {
            // Fallback: use the file's directory structure relative to project root
            const projectRoot = process.cwd();
            const normalizedProjectRoot = resolve(projectRoot).replace(/\\/g, '/');
            if (normalizedOriginalPath.startsWith(normalizedProjectRoot + '/')) {
                relativePath = normalizedOriginalPath.slice(normalizedProjectRoot.length + 1);
            } else {
                relativePath = basename(originalPath);
            }
        }
        
        const targetPath = join(tempDir, relativePath);
        await mkdir(dirname(targetPath), { recursive: true });
        await writeFile(targetPath, instrumentedCode);
    }
}


async function runElmTest(tempDir: string, runner: string, forwardedArgs: string[], compilerWrapper: string): Promise<CoverageData> {
    const env = {
        ...process.env,
        PATH: `${dirname(compilerWrapper)}:${process.env['PATH'] || ''}`,
    };
    
    const args = [
        '--compiler',
        compilerWrapper,
        ...forwardedArgs,
    ];
    
    await execFileAsync(runner, args, {
        cwd: tempDir,
        env,
    });
    
    // Read coverage data from all worker processes
    const coverageData = new Map<number, number>();
    const elmStuffDir = join(tempDir, 'elm-stuff');
    
    try {
        const files = await readdir(elmStuffDir);
        const coverageFiles = files.filter(f => f.startsWith('coverage-') && f.endsWith('.json'));
        
        for (const file of coverageFiles) {
            const filePath = join(elmStuffDir, file);
            const content = await readFile(filePath, 'utf-8');
            const counters: Record<string, number> = JSON.parse(content);
            
            // Combine counters: pointId -> count
            for (const [pointIdStr, count] of Object.entries(counters)) {
                const pointId = Number(pointIdStr);
                coverageData.set(pointId, (coverageData.get(pointId) || 0) + count);
            }
        }
    } catch (error) {
        // If elm-stuff doesn't exist or no coverage files found, return empty map
        // This might happen if tests failed before writing coverage data
    }
    
    return coverageData;
}

function getFileExtensionForFormat(format: ReportFormat): string {
    switch (format) {
        case 'lcov':
            return 'lcov';
        case 'html':
            return 'html';
        case 'csv':
            return 'csv';
        case 'plaintext':
            return 'txt';
        default:
            return 'txt';
    }
}

function generateDateTimeString(date: Date): string {
    const pad = (n: number) => n.toString().padStart(2, '0');
    return [
        date.getFullYear(),
        date.getMonth() + 1,
        date.getDate(),
        date.getHours(),
        date.getMinutes(),
        date.getSeconds()
    ].map(pad).join('-');
}

async function writeReport(reportFiles: Report, format: ReportFormat, output?: string): Promise<void> {
    if (format === 'stdout') {
        // For stdout, just print the first file's contents
        if (reportFiles[0]) {
            console.log(reportFiles[0].contents);
        }
        return;
    }
    
    const ext = getFileExtensionForFormat(format);
    
    // If no output is specified, generate a default output path in elm-stuff/coverage-report-YYYY-MM-DD-HH-MM-SS.EXT
    if (!output) {
        const now = new Date();
        const dateTimeStr = generateDateTimeString(now);
        // HTML reports are directories, so don't add extension
        output = join(
            'elm-stuff',
            `coverage-report-${dateTimeStr}${ext === 'html' ? '' : '.' + ext}`
        );
    }
    
    if (ext === 'html') {
        // HTML reports go to a folder
        await mkdir(output, { recursive: true });
        for (const file of reportFiles) {
            const filePath = join(output, file.filepath);
            await mkdir(dirname(filePath), { recursive: true });
            await writeFile(filePath, file.contents);
        }
    } else {
        // Other formats: if single file, use the output path; otherwise use filepath from report
        if (reportFiles[0]) {
            await writeFile(output, reportFiles[0].contents);
        } else {
            // Multiple files: write each to the output directory
            await mkdir(output, { recursive: true });
            for (const file of reportFiles) {
                const filePath = join(output, file.filepath);
                await mkdir(dirname(filePath), { recursive: true });
                await writeFile(filePath, file.contents);
            }
        }
    }
}

async function readElmJson(projectDir: string): Promise<{ content: string; sourceDirs: string[] }> {
    const elmJsonPath = join(projectDir, 'elm.json');
    const content = await readFile(elmJsonPath, 'utf-8');
    const elmJson = JSON.parse(content);
    
    const sourceDirs = elmJson['source-directories'] || ['src'];
    const absoluteSourceDirs = sourceDirs.map((dir: string) => resolve(projectDir, dir));
    
    return { content, sourceDirs: absoluteSourceDirs };
}

async function main() {
    const args = parseArgs();
    const projectDir = process.cwd();
    await ensureElmProjectRoot(projectDir);
    const { content: elmJsonContent, sourceDirs } = await readElmJson(projectDir);
    const elmFiles = await findElmFiles(projectDir);
    const { coverageMetadata, instrumentedFiles, moduleMetadata } = await instrumentFiles(elmFiles);
    
    // Collect original sources by module name
    // Extract module name from file content (first line: "module Module.Name exposing (...)")
    const sourcesByModule = new Map<string, string>();
    for (const filePath of elmFiles) {
        const sourceCode = await readFile(filePath, 'utf-8');
        // Extract module name from the module declaration
        const lines = sourceCode.split('\n');
        for (const line of lines) {
            const trimmed = line.trim();
            if (trimmed.startsWith('module ')) {
                const moduleMatch = trimmed.match(/^module\s+([A-Z][A-Za-z0-9_.]*)\s+exposing/);
                if (moduleMatch && moduleMatch[1]) {
                    const moduleName = moduleMatch[1];
                    sourcesByModule.set(moduleName, sourceCode);
                    break;
                }
            }
        }
    }
    
    const tempDir = join(projectDir, 'elm-stuff', 'instrumented-project');
    await mkdir(tempDir, { recursive: true });
    try {
        await createTempProject(tempDir, instrumentedFiles, elmJsonContent, sourceDirs);
        const binDir = getBinDirectory();
        const compilerWrapper = join(binDir, 'elm-compiler-wrapper');
        const coverageData = await runElmTest(tempDir, args.runner, args.forwardedArgs, compilerWrapper);
        const reportContent = await report(coverageMetadata, coverageData, args.coverageFormat, sourcesByModule, moduleMetadata);
        await writeReport(reportContent, args.coverageFormat, args.coverageOutput);
    } finally {
        await rm(tempDir, { recursive: true, force: true });
    }
}

main().catch((error) => {
    console.error('Error:', error);
    process.exit(1);
});
