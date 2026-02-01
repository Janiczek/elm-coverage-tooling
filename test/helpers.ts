import { spawn } from 'child_process';
import { readFile, readdir, stat, access, mkdir, copyFile } from 'fs/promises';
import { join } from 'path';
import assert from 'node:assert';

export type ReportFormat = 'stdout' | 'html' | 'lcov' | 'csv' | 'plaintext';

export interface FixtureFlags {
    hasExpectedInstrumentedProject: boolean;
    hasExpectedCoverageJson: boolean;
    hasExpectedMetadataJson: boolean;
}

export interface FormatInfo {
    format: ReportFormat;
    expectedFileName: string;
}

/**
 * Strips ANSI escape codes from a string.
 * ANSI escape codes are used for terminal colors and formatting.
 */
export function stripAnsiCodes(text: string): string {
    // ANSI escape codes start with ESC (0x1B) followed by [ and end with m
    // This regex matches: \x1b[ or \u001b[ followed by any characters until m
    return text.replace(/\u001b\[[0-9;]*m/g, '');
}

export function runCommand(
    command: string,
    args: string[],
    options?: { cwd?: string }
): Promise<{ stdout: string; stderr: string; code: number | null }> {
    return new Promise((resolve) => {
        const child = spawn(command, args, {
            cwd: options?.cwd || process.cwd(),
            stdio: ['ignore', 'pipe', 'pipe'],
        });

        let stdout = '';
        let stderr = '';

        child.stdout?.on('data', (data) => {
            stdout += data.toString();
        });

        child.stderr?.on('data', (data) => {
            stderr += data.toString();
        });

        child.on('close', (code) => {
            resolve({ stdout, stderr, code });
        });
    });
}

export async function readExpectedFile(fixturePath: string, filename: string): Promise<string | null> {
    const filePath = join(fixturePath, filename);
    try {
        await access(filePath);
        return await readFile(filePath, 'utf-8');
    } catch {
        return null;
    }
}

export async function findExpectedReportFiles(fixturePath: string): Promise<string[]> {
    const files: string[] = [];
    try {
        const entries = await readdir(fixturePath);
        for (const entry of entries) {
            // Match both expected-report-* (for directories like expected-report-html)
            // and expected-report.* (for files like expected-report.csv, expected-report.lcov, etc.)
            if (entry.startsWith('expected-report-') || entry.startsWith('expected-report.')) {
                files.push(entry);
            }
        }
    } catch {
        // Directory doesn't exist or can't be read
    }
    return files;
}

export async function copyDirectory(src: string, dest: string, excludeDirs: Set<string> = new Set(['elm-stuff'])): Promise<void> {
    await mkdir(dest, { recursive: true });
    const entries = await readdir(src);
    for (const entry of entries) {
        if (excludeDirs.has(entry)) {
            continue;
        }

        const srcPath = join(src, entry);
        const destPath = join(dest, entry);
        const stats = await stat(srcPath);

        if (stats.isDirectory()) {
            await copyDirectory(srcPath, destPath, excludeDirs);
        } else if (stats.isFile()) {
            await copyFile(srcPath, destPath);
        }
    }
}

export async function compareDirectories(expected: string, actual: string, basePath: string = ''): Promise<void> {
    const expectedEntries = await readdir(expected);
    const actualEntries = await readdir(actual);
    
    // Exclude elm-stuff (can contain previous coverage data)
    const filteredExpectedEntries = expectedEntries.filter(entry => entry !== 'elm-stuff');
    const filteredActualEntries = actualEntries.filter(entry => entry !== 'elm-stuff');
    
    // Check that all expected entries exist in actual
    for (const entry of filteredExpectedEntries) {
        const expectedPath = join(expected, entry);
        const actualPath = join(actual, entry);
        const relativePath = basePath ? join(basePath, entry) : entry;
        
        const expectedStats = await stat(expectedPath);
        const actualStats = await stat(actualPath);
        
        if (expectedStats.isDirectory() && actualStats.isDirectory()) {
            await compareDirectories(expectedPath, actualPath, relativePath);
        } else if (expectedStats.isFile() && actualStats.isFile()) {
            const expectedContent = await readFile(expectedPath, 'utf-8');
            const actualContent = await readFile(actualPath, 'utf-8');
            assert.strictEqual(
                actualContent,
                expectedContent,
                `File content mismatch in ${relativePath}`
            );
        } else {
            throw new Error(`Type mismatch for ${relativePath}: expected ${expectedStats.isDirectory() ? 'directory' : 'file'}, got ${actualStats.isDirectory() ? 'directory' : 'file'}`);
        }
    }
    
    // Check that there are no extra entries in actual (excluding the excluded directories)
    const expectedSet = new Set(filteredExpectedEntries);
    const extraEntries = filteredActualEntries.filter(entry => !expectedSet.has(entry));
    if (extraEntries.length > 0) {
        throw new Error(`Unexpected entries in ${basePath || 'root'}: ${extraEntries.join(', ')}`);
    }
}

/**
 * Checks if a file exists at the given path.
 */
export async function checkFileExists(filePath: string): Promise<boolean> {
    try {
        await access(filePath);
        return true;
    } catch {
        return false;
    }
}

/**
 * Finds report files in elm-stuff directory by extension.
 * For HTML reports, looks for 'coverage-report' directory.
 * For other formats, looks for files starting with 'coverage-report' and ending with the extension.
 */
export async function findReportFiles(elmStuffPath: string, extension: string): Promise<string[]> {
    const files: string[] = [];
    try {
        const entries = await readdir(elmStuffPath);
        for (const entry of entries) {
            const entryPath = join(elmStuffPath, entry);
            const stats = await stat(entryPath);
            if (extension === 'html') {
                // HTML reports use fixed folder name: coverage-report
                if (entry === 'coverage-report' && stats.isDirectory()) {
                    files.push(entryPath);
                }
            } else {
                // Other formats are files starting with coverage-report and ending with extension
                if (entry.startsWith('coverage-report') && stats.isFile() && entry.endsWith('.' + extension)) {
                    files.push(entryPath);
                }
            }
        }
    } catch {
        // Directory doesn't exist
    }
    // Sort by name, most recent first
    files.sort((a, b) => {
        return b.localeCompare(a);
    });
    return files;
}

/**
 * Detects the report format from a report file name.
 */
export async function detectReportFormat(fixturePath: string, reportFile: string): Promise<ReportFormat | null> {
    const reportFilePath = join(fixturePath, reportFile);
    let isDirectory = false;
    try {
        const stats = await stat(reportFilePath);
        isDirectory = stats.isDirectory();
    } catch {
        // File doesn't exist, skip
        return null;
    }
    
    if (reportFile.includes('stdout')) {
        return 'stdout';
    } else if (reportFile.endsWith('.lcov')) {
        return 'lcov';
    } else if (reportFile.endsWith('.html') || (isDirectory && reportFile.includes('html'))) {
        return 'html';
    } else if (reportFile.endsWith('.csv')) {
        return 'csv';
    } else if (reportFile.endsWith('.txt')) {
        return 'plaintext';
    }
    
    return null;
}

/**
 * Groups expected report files by format.
 */
export async function groupReportFilesByFormat(fixturePath: string, expectedReportFiles: string[]): Promise<Map<ReportFormat, string[]>> {
    const reportsByFormat = new Map<ReportFormat, string[]>();
    for (const reportFile of expectedReportFiles) {
        const format = await detectReportFormat(fixturePath, reportFile);
        if (format) {
            if (!reportsByFormat.has(format)) {
                reportsByFormat.set(format, []);
            }
            reportsByFormat.get(format)!.push(reportFile);
        }
    }
    return reportsByFormat;
}

/**
 * Determines which flags to use based on existing expected files in the fixture.
 */
export async function detectFixtureFlags(fixturePath: string): Promise<FixtureFlags> {
    const expectedInstrumentedProjectPath = join(fixturePath, 'expected-instrumented-project');
    let hasExpectedInstrumentedProject = false;
    try {
        const stats = await stat(expectedInstrumentedProjectPath);
        hasExpectedInstrumentedProject = stats.isDirectory();
    } catch {
        // Doesn't exist
    }
    const hasExpectedCoverageJson = await checkFileExists(join(fixturePath, 'expected-coverage.json'));
    const hasExpectedMetadataJson = await checkFileExists(join(fixturePath, 'expected-metadata.json'));
    
    return {
        hasExpectedInstrumentedProject,
        hasExpectedCoverageJson,
        hasExpectedMetadataJson
    };
}

/**
 * Reads cmdline file and returns the arguments as an array.
 */
export async function readCmdlineArgs(fixturePath: string): Promise<string[]> {
    const cmdlineFile = await readExpectedFile(fixturePath, 'cmdline');
    return cmdlineFile 
        ? cmdlineFile.trim().split(/\s+/).filter(arg => arg.length > 0)
        : [];
}

/**
 * Builds command arguments for elm-coverage-test based on format and flags.
 */
export function buildCommandArgs(
    format: ReportFormat,
    flags: FixtureFlags,
    cmdlineArgs: string[]
): string[] {
    const args: string[] = [];
    if (flags.hasExpectedInstrumentedProject) {
        args.push('--keep-instrumented-project');
    }
    if (flags.hasExpectedCoverageJson) {
        args.push('--keep-coverage-data');
    }
    if (format !== 'stdout') {
        args.push('--coverage-format', format);
    }
    // Add cmdline arguments (these will be forwarded to elm-test)
    args.push(...cmdlineArgs);
    return args;
}

/**
 * Gets the file extension for a given report format.
 */
export function getFormatExtension(format: ReportFormat): string {
    switch (format) {
        case 'lcov':
            return 'lcov';
        case 'html':
            return 'html';
        case 'csv':
            return 'csv';
        case 'plaintext':
            return 'txt';
        case 'stdout':
            return '';
        default:
            return '';
    }
}

/**
 * Gets all available report formats with their expected file names.
 */
export function getAllFormats(): FormatInfo[] {
    return [
        { format: 'stdout', expectedFileName: 'expected.stdout' },
        { format: 'html', expectedFileName: 'expected-report-html' },
        { format: 'lcov', expectedFileName: 'expected-report.lcov' },
        { format: 'csv', expectedFileName: 'expected-report.csv' },
        { format: 'plaintext', expectedFileName: 'expected-report.txt' },
    ];
}
