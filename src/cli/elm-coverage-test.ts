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
    keepInstrumentedProject: boolean;
    keepCoverageData: boolean;
    forwardedArgs: string[];
}

function parseArgs(): CliArgs {
    const args = hideBin(process.argv);
    
    const yargsInstance = yargs(args)
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
        .option('keep-instrumented-project', {
            type: 'boolean',
            default: false,
            description: 'Keep the instrumented project in elm-stuff/instrumented-project and write coverage-metadata.json',
        })
        .option('keep-coverage-data', {
            type: 'boolean',
            default: false,
            description: 'Write merged coverage data to elm-stuff/coverage.json',
        })
        .strict(false) // Allow unknown options to be forwarded
        .help();
    
    // Only show help if --help is explicitly passed
    if (args.includes('--help') || args.includes('-h')) {
        yargsInstance.showHelp();
        process.exit(0);
    }
    
    const argv = yargsInstance.parseSync();

    const runner = argv.runner as string;
    const coverageFormat = argv['coverage-format'] as ReportFormat;
    const coverageOutput = argv['coverage-output'] as string | undefined;
    const keepInstrumentedProject = argv['keep-instrumented-project'] as boolean;
    const keepCoverageData = argv['keep-coverage-data'] as boolean;

    const forwardedArgs: string[] = [];
    const knownFlags = new Set(['--runner', '--coverage-format', '--coverage-output', '--keep-instrumented-project', '--keep-coverage-data']);
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
            arg.startsWith('--coverage-output=') ||
            arg.startsWith('--keep-instrumented-project=') ||
            arg.startsWith('--keep-coverage-data='))
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
        keepInstrumentedProject,
        keepCoverageData,
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

async function instrumentFiles(
    elmFiles: string[],
    projectDir: string,
    sourceDirs: string[],
    sourceDirNames: string[]
): Promise<{ 
    coverageMetadata: CoverageMetadataMap, 
    instrumentedFiles: Map<string, string>,
    moduleMetadata: ModuleMetadata,
    originalSources: Map<string, string>
}> {
    const coverageMetadatas: CoverageMetadataMap[] = [];
    const instrumentedFiles = new Map<string, string>();
    const moduleMetadata: ModuleMetadata = new Map<string, number>();
    const originalSources = new Map<string, string>();
    
    for (const filePath of elmFiles) {
        const sourceCode = await readFile(filePath, 'utf-8');
        const output = await instrument(sourceCode);
        
        if ('error' in output) {
            console.error(`Error instrumenting ${filePath}: ${output.error}`);
            process.exit(1);
        }
        
        // Calculate relative filepath (includes source directory)
        const relativeFilePath = calculateRelativeFilePath(filePath, projectDir, sourceDirs, sourceDirNames);
        
        // Store instrumented code keyed by relative path for easier use in createTempProject
        instrumentedFiles.set(relativeFilePath, output.instrumentedElmSourceCode);
        
        // Enrich coverage metadata with filepaths
        const enrichedMetadata: CoverageMetadataMap = new Map();
        for (const [pointId, meta] of output.coverageMetadata.entries()) {
            enrichedMetadata.set(pointId, {
                ...meta,
                moduleFilePath: relativeFilePath
            });
        }
        
        coverageMetadatas.push(enrichedMetadata);
        moduleMetadata.set(filePath, output.contentHash);
        // Store original source code for later use in reporting
        originalSources.set(filePath, sourceCode);
    }

    const coverageMetadata: CoverageMetadataMap = new Map(coverageMetadatas.flatMap(m => [...m]));
    
    return { coverageMetadata, instrumentedFiles, moduleMetadata, originalSources };
}

async function createTempProject(
    tempDir: string,
    instrumentedFiles: Map<string, string>,
    otherFiles: string[],
    originalElmJson: string,
    projectDir: string
): Promise<void> {
    // Copy elm.json
    await writeFile(join(tempDir, 'elm.json'), originalElmJson);
    
    // Parse elm.json to get source directories relative to project root
    const elmJson = JSON.parse(originalElmJson);
    const sourceDirs = elmJson['source-directories'] || ['src'];
    
    // Create all source directories (even if empty) to satisfy elm.json requirements
    for (const sourceDir of sourceDirs) {
        const targetSourceDir = join(tempDir, sourceDir);
        await mkdir(targetSourceDir, { recursive: true });
    }
    
    const normalizedProjectRoot = resolve(projectDir).replace(/\\/g, '/');
    
    // Copy instrumented source files (already keyed by relative path)
    for (const [relativePath, instrumentedCode] of instrumentedFiles.entries()) {
        const targetPath = join(tempDir, relativePath);
        await mkdir(dirname(targetPath), { recursive: true });
        await writeFile(targetPath, instrumentedCode);
    }
    
    // Copy other files (like tests) as-is
    for (const originalPath of otherFiles) {
        const normalizedOriginalPath = resolve(originalPath).replace(/\\/g, '/');
        let relativePath: string;
        if (normalizedOriginalPath.startsWith(normalizedProjectRoot + '/')) {
            relativePath = normalizedOriginalPath.slice(normalizedProjectRoot.length + 1);
        } else {
            relativePath = basename(originalPath);
        }
        
        const targetPath = join(tempDir, relativePath);
        await mkdir(dirname(targetPath), { recursive: true });
        const originalContent = await readFile(originalPath, 'utf-8');
        await writeFile(targetPath, originalContent);
    }
}

async function runElmTest(tempDir: string, runner: string, forwardedArgs: string[], compilerWrapper: string): Promise<{ coverageData: CoverageData; testFailed: boolean; error?: any }> {
    const env = {
        ...process.env,
        PATH: `${dirname(compilerWrapper)}:${process.env['PATH'] || ''}`,
    };
    
    const args = [
        '--compiler',
        compilerWrapper,
        ...forwardedArgs,
    ];
    
    let testFailed = false;
    let testError: any = null;
    
    try {
        await execFileAsync(runner, args, {
            cwd: tempDir,
            env,
        });
    } catch (error) {
        // Tests failed, but we still want to collect coverage data from tests that ran
        testFailed = true;
        testError = error;
    }
    
    // Read coverage data from all worker processes (even if tests failed)
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
    
    return { coverageData, testFailed, error: testError };
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

async function writeReport(reportFiles: Report, format: ReportFormat, output?: string): Promise<void> {
    if (format === 'stdout') {
        // For stdout, just print the first file's contents
        if (reportFiles[0]) {
            console.log(reportFiles[0].contents);
        }
        return;
    }
    
    const ext = getFileExtensionForFormat(format);
    
    // If no output is specified, generate a default output path
    // HTML reports: elm-stuff/coverage-report (fixed folder name)
    // Other formats: elm-stuff/coverage-report.EXT
    if (!output) {
        if (ext === 'html') {
            output = join('elm-stuff', 'coverage-report');
        } else {
            output = join('elm-stuff', `coverage-report.${ext}`);
        }
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

async function readElmJson(projectDir: string): Promise<{ content: string; sourceDirs: string[]; sourceDirNames: string[] }> {
    const elmJsonPath = join(projectDir, 'elm.json');
    const content = await readFile(elmJsonPath, 'utf-8');
    const elmJson = JSON.parse(content);
    
    const sourceDirNames = elmJson['source-directories'] || ['src'];
    const absoluteSourceDirs = sourceDirNames.map((dir: string) => resolve(projectDir, dir));
    
    return { content, sourceDirs: absoluteSourceDirs, sourceDirNames };
}

function calculateRelativeFilePath(filePath: string, projectDir: string, sourceDirs: string[], sourceDirNames: string[]): string {
    const normalizedProjectRoot = resolve(projectDir).replace(/\\/g, '/');
    const normalizedOriginalPath = resolve(filePath).replace(/\\/g, '/');
    const normalizedSourceDirs = sourceDirs.map(dir => resolve(dir).replace(/\\/g, '/'));
    
    // Try to find which source directory this file belongs to
    for (let i = 0; i < normalizedSourceDirs.length; i++) {
        const sourceDir = normalizedSourceDirs[i];
        const sourceDirName = sourceDirNames[i];
        
        if (sourceDir && sourceDirName && (normalizedOriginalPath.startsWith(sourceDir + '/') || normalizedOriginalPath === sourceDir)) {
            const fileRelativeToSource = normalizedOriginalPath.slice(sourceDir.length);
            // Build path: sourceDirName + fileRelativeToSource
            // Remove leading slash from fileRelativeToSource if present, add it if not
            const relativePath = sourceDirName + (fileRelativeToSource.startsWith('/') ? fileRelativeToSource : '/' + fileRelativeToSource);
            return relativePath.replace(/\\/g, '/');
        }
    }
    
    // Fallback: use the file's directory structure relative to project root
    if (normalizedOriginalPath.startsWith(normalizedProjectRoot + '/')) {
        return normalizedOriginalPath.slice(normalizedProjectRoot.length + 1).replace(/\\/g, '/');
    } else {
        return basename(filePath);
    }
}

function serializeCoverageMetadata(metadata: CoverageMetadataMap): Record<string, { moduleName: string; moduleFilePath: string; declarationName: string; range: [[number, number], [number, number]]; category: string }> {
    const result: Record<string, { moduleName: string; moduleFilePath: string; declarationName: string; range: [[number, number], [number, number]]; category: string }> = {};
    for (const [pointId, meta] of metadata.entries()) {
        result[pointId.toString()] = {
            moduleName: meta.moduleName,
            moduleFilePath: meta.moduleFilePath,
            declarationName: meta.declarationName,
            range: meta.range,
            category: meta.category,
        };
    }
    return result;
}

function serializeCoverageData(data: CoverageData): Record<string, number> {
    const result: Record<string, number> = {};
    for (const [pointId, count] of data.entries()) {
        result[pointId.toString()] = count;
    }
    return result;
}

async function cleanupCoverageFiles(projectDir: string): Promise<void> {
    const elmStuffPath = join(projectDir, 'elm-stuff');
    const coverageFiles = [
        'coverage-metadata.json',
        'coverage-report',
        'coverage-report.csv',
        'coverage-report.lcov',
        'coverage-report.txt',
        'coverage.json',
        'instrumented-project',
    ];
    
    for (const file of coverageFiles) {
        const filePath = join(elmStuffPath, file);
        try {
            await rm(filePath, { recursive: true, force: true });
        } catch {
            // File doesn't exist, which is fine
        }
    }
}

async function main() {
    const args = parseArgs();
    const projectDir = process.cwd();
    await ensureElmProjectRoot(projectDir);
    
    // Clean up coverage-related files at the very beginning
    await cleanupCoverageFiles(projectDir);
    
    const { content: elmJsonContent, sourceDirs, sourceDirNames } = await readElmJson(projectDir);
    const allElmFiles = await findElmFiles(projectDir);
    
    // Separate source files (to instrument) from other files (to copy as-is, like tests)
    const sourceFiles: string[] = [];
    const otherFiles: string[] = [];
    const normalizedSourceDirs = sourceDirs.map(dir => resolve(dir).replace(/\\/g, '/'));
    
    for (const filePath of allElmFiles) {
        const normalizedPath = resolve(filePath).replace(/\\/g, '/');
        const isInSourceDir = normalizedSourceDirs.some(sourceDir => 
            normalizedPath.startsWith(sourceDir + '/')
        );
        if (isInSourceDir) {
            sourceFiles.push(filePath);
        } else {
            otherFiles.push(filePath);
        }
    }
    
    const { coverageMetadata, instrumentedFiles, moduleMetadata, originalSources } = await instrumentFiles(sourceFiles, projectDir, sourceDirs, sourceDirNames);
    
    // Collect original sources by filepath (only from source files, not test files)
    // Use the same source code that was used for hash calculation to avoid hash mismatches
    // Extract module name from file content (first line: "module Module.Name exposing (...)")
    const sourcesByFilepath = new Map<string, string>();
    const moduleHashesByFilepath = new Map<string, number>();
    const moduleNamesByFilepath = new Map<string, string>(); // filepath -> moduleName
    for (const filePath of sourceFiles) {
        const sourceCode = originalSources.get(filePath);
        if (!sourceCode) {
            continue; // Should not happen, but skip if missing
        }
        const hash = moduleMetadata.get(filePath);
        if (hash === undefined) {
            continue; // Should not happen, but skip if missing
        }
        // Calculate relative filepath (includes source directory)
        const relativeFilePath = calculateRelativeFilePath(filePath, projectDir, sourceDirs, sourceDirNames);
        
        // Extract module name from the module declaration
        const lines = sourceCode.split('\n');
        for (const line of lines) {
            const trimmed = line.trim();
            if (trimmed.startsWith('module ')) {
                const moduleMatch = trimmed.match(/^module\s+([A-Z][A-Za-z0-9_.]*)\s+exposing/);
                if (moduleMatch && moduleMatch[1]) {
                    const moduleName = moduleMatch[1];
                    sourcesByFilepath.set(relativeFilePath, sourceCode);
                    moduleHashesByFilepath.set(relativeFilePath, hash);
                    moduleNamesByFilepath.set(relativeFilePath, moduleName);
                    break;
                }
            }
        }
    }
    
    const tempDir = join(projectDir, 'elm-stuff', 'instrumented-project');
    await mkdir(tempDir, { recursive: true });
    
    // Write coverage-metadata.json if --keep-instrumented-project is set
    if (args.keepInstrumentedProject) {
        const metadataPath = join(projectDir, 'elm-stuff', 'coverage-metadata.json');
        await mkdir(dirname(metadataPath), { recursive: true });
        const serializedMetadata = serializeCoverageMetadata(coverageMetadata);
        await writeFile(metadataPath, JSON.stringify(serializedMetadata, null, 2));
    }
    
    try {
        await createTempProject(tempDir, instrumentedFiles, otherFiles, elmJsonContent, projectDir);
        const binDir = getBinDirectory();
        const compilerWrapper = join(binDir, 'elm-compiler-wrapper');
        const { coverageData, testFailed, error: testError } = await runElmTest(tempDir, args.runner, args.forwardedArgs, compilerWrapper);
        
        // Write coverage.json if --keep-coverage-data is set
        if (args.keepCoverageData) {
            const coveragePath = join(projectDir, 'elm-stuff', 'coverage.json');
            await mkdir(dirname(coveragePath), { recursive: true });
            const serializedData = serializeCoverageData(coverageData);
            await writeFile(coveragePath, JSON.stringify(serializedData, null, 2));
        }
        
        const reportContent = await report(coverageMetadata, coverageData, args.coverageFormat, sourcesByFilepath, moduleHashesByFilepath, moduleNamesByFilepath);
        await writeReport(reportContent, args.coverageFormat, args.coverageOutput);
        
        // If tests failed, re-throw the error so the process exits with the correct code
        if (testFailed && testError) {
            throw testError;
        }
    } finally {
        // Only delete tempDir if --keep-instrumented-project is not set
        if (!args.keepInstrumentedProject) {
            await rm(tempDir, { recursive: true, force: true });
        }
    }
}

main().catch((error) => {
    // If the error has stderr (from execFileAsync), just print that
    if (error && typeof error === 'object' && 'stderr' in error && typeof error.stderr === 'string') {
        console.error(error.stderr);
    } else {
        console.error('Error:', error);
    }
    process.exit(1);
});
