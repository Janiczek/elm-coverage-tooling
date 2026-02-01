import test from 'node:test';
import assert from 'node:assert';
import { resolve, join } from 'path';
import { readdir, stat, readFile, rm } from 'fs/promises';
import {
    runCommand,
    readExpectedFile,
    findExpectedReportFiles,
    compareDirectories,
    stripAnsiCodes,
    copyDirectory,
    checkFileExists,
    findReportFiles,
    groupReportFilesByFormat,
    detectFixtureFlags,
    readCmdlineArgs,
    buildCommandArgs,
    getFormatExtension,
    type ReportFormat
} from './helpers.ts';

const binaryPath = resolve(process.cwd(), 'bin', 'elm-coverage-test');
const fixturesPath = resolve(process.cwd(), 'test', 'elm-coverage-test-fixtures');

test('elm-coverage-test CLI', async (t) => {
    await t.test('shows usage when run with --help', async () => {
        const { stdout, stderr, code } = await runCommand(binaryPath, ['--help']);
        
        assert(
            (stdout.includes('--runner') || stderr.includes('--runner')) && 
            (stdout.includes('--coverage-format') || stderr.includes('--coverage-format')),
            `Expected help output with --runner and --coverage-format, but stdout was: ${stdout}, stderr was: ${stderr}`
        );
        
        assert.strictEqual(code, 0, `Expected exit code 0, but got: ${code}`);
    });
});

test('elm-coverage-test e2e fixtures', async (t) => {
    // Auto-discover fixtures
    let fixtureDirs: string[] = [];
    try {
        const entries = await readdir(fixturesPath);
        for (const entry of entries) {
            const entryPath = join(fixturesPath, entry);
            const stats = await stat(entryPath);
            if (stats.isDirectory()) {
                fixtureDirs.push(entry);
            }
        }
    } catch (error) {
        // Fixtures directory doesn't exist, skip e2e tests
        return;
    }

    // Filter fixtures if FIXTURE environment variable is set
    const fixtureFilter = process.env.FIXTURE;
    if (fixtureFilter) {
        fixtureDirs = fixtureDirs.filter(name => name === fixtureFilter);
        if (fixtureDirs.length === 0) {
            throw new Error(`No fixture found matching: ${fixtureFilter}`);
        }
    }

    // Run tests for each fixture
    for (const fixtureName of fixtureDirs) {
        await t.test(fixtureName, async (fixtureTest) => {
            const fixturePath = join(fixturesPath, fixtureName);
            const projectPath = join(fixturePath, 'project');
            
            // Check if project directory exists
            try {
                await stat(projectPath);
            } catch {
                // Skip fixtures without project directory
                return;
            }
            
            // Determine which flags to use based on expected files
            const flags = await detectFixtureFlags(fixturePath);
            const expectedReportFiles = await findExpectedReportFiles(fixturePath);
            const reportsByFormat = await groupReportFilesByFormat(fixturePath, expectedReportFiles);
            
            // If no report files, default to stdout
            // Always include stdout first to match approval script behavior (stdout is used for return code/stderr checks)
            const formatsToTest: ReportFormat[] = reportsByFormat.size > 0 
                ? (reportsByFormat.has('stdout') 
                    ? Array.from(reportsByFormat.keys()) 
                    : ['stdout', ...Array.from(reportsByFormat.keys())])
                : ['stdout'];
            
            // Read cmdline file if it exists
            const cmdlineArgs = await readCmdlineArgs(fixturePath);
            
            // Run the tool for each format and store report content immediately after each run
            // This ensures we capture the report before the next command run potentially overwrites it
            const commandResults = new Map<string, { stdout: string; stderr: string; code: number | null }>();
            const reportContents = new Map<string, { content: string | null; path: string | null; isDirectory: boolean }>();
            const tempDirectories: string[] = []; // Track temp directories for cleanup
            let firstFormatResult: { stdout: string; stderr: string; code: number | null } | null = null;
            let stdoutResult: { stdout: string; stderr: string; code: number | null } | null = null;
            let capturedCoverageJson: { content: any; exists: boolean } | null = null;
            
            for (const format of formatsToTest) {
                // Build command args
                const args = buildCommandArgs(format, flags, cmdlineArgs);
                
                // Run the command from the project directory
                const result = await runCommand(binaryPath, args, { cwd: projectPath });
                commandResults.set(format, result);
                
                // Store stdout result separately for return code/stderr checks (matching approval script behavior)
                if (format === 'stdout') {
                    stdoutResult = result;
                }
                
                // Store first format result for validations that only run once
                if (firstFormatResult === null) {
                    firstFormatResult = result;
                    // Capture coverage.json after first format run (before it gets overwritten)
                    if (flags.hasExpectedCoverageJson) {
                        const actualCoveragePath = join(projectPath, 'elm-stuff', 'coverage.json');
                        const actualCoverageExists = await checkFileExists(actualCoveragePath);
                        if (actualCoverageExists) {
                            const actualCoverageContent = await readFile(actualCoveragePath, 'utf-8');
                            capturedCoverageJson = {
                                content: JSON.parse(actualCoverageContent),
                                exists: true
                            };
                        } else {
                            capturedCoverageJson = {
                                content: null,
                                exists: false
                            };
                        }
                    }
                }
                
                // Capture report files for this format immediately after running the command
                const formatReportFiles = reportsByFormat.get(format) || [];
                
                // Skip stdout format files (will be validated separately)
                if (format !== 'stdout') {
                    for (const expectedReportFile of formatReportFiles) {
                        const extension = getFormatExtension(format);
                        
                        if (!extension) {
                            continue;
                        }
                        
                        // Find and read the actual report file(s) immediately after command runs
                        const elmStuffPath = join(projectPath, 'elm-stuff');
                        const reportFiles = await findReportFiles(elmStuffPath, extension);
                        
                        const reportKey = `${format}:${expectedReportFile}`;
                        if (format === 'html') {
                            // HTML reports are directories - copy to temp location to avoid cleanup
                            if (reportFiles.length > 0) {
                                // Use a unique temp directory name based on the report key
                                const tempHtmlReportPath = join(fixturePath, `.temp-${reportKey.replace(/[^a-zA-Z0-9]/g, '-')}`);
                                try {
                                    await rm(tempHtmlReportPath, { recursive: true, force: true });
                                } catch {
                                    // Doesn't exist, which is fine
                                }
                                await copyDirectory(reportFiles[0], tempHtmlReportPath);
                                tempDirectories.push(tempHtmlReportPath); // Track for cleanup
                                reportContents.set(reportKey, {
                                    content: null,
                                    path: tempHtmlReportPath,
                                    isDirectory: true
                                });
                            } else {
                                reportContents.set(reportKey, {
                                    content: null,
                                    path: null,
                                    isDirectory: true
                                });
                            }
                        } else {
                            // Other formats are single files - read and store the content
                            const content = reportFiles.length > 0 
                                ? await readFile(reportFiles[0], 'utf-8')
                                : null;
                            reportContents.set(reportKey, {
                                content,
                                path: reportFiles.length > 0 ? reportFiles[0] : null,
                                isDirectory: false
                            });
                        }
                    }
                }
            }
            
            // Now create tests for all reports using the captured content
            for (const format of formatsToTest) {
                const formatReportFiles = reportsByFormat.get(format) || [];
                
                // Skip stdout format files (will be validated separately)
                if (format !== 'stdout') {
                    for (const expectedReportFile of formatReportFiles) {
                        const extension = getFormatExtension(format);
                        
                        if (!extension) {
                            continue;
                        }
                        
                        const reportKey = `${format}:${expectedReportFile}`;
                        const reportData = reportContents.get(reportKey);
                        
                        // Create a test for each report file
                        const formatName = format.toUpperCase();
                        const testName = formatReportFiles.length > 1 
                            ? `report: ${formatName} (${expectedReportFile})`
                            : `report: ${formatName}`;
                        await fixtureTest.test(testName, async () => {
                            if (format === 'html') {
                                // HTML reports are directories
                                if (!reportData || !reportData.path) {
                                    throw new Error(`No HTML report directory found`);
                                }
                                const actualReportDir = reportData.path;
                                const expectedReportPath = join(fixturePath, expectedReportFile);
                                // For HTML, expected-report-*.html should be a directory
                                let expectedReportDir = expectedReportPath;
                                try {
                                    const expectedStats = await stat(expectedReportPath);
                                    if (expectedStats.isDirectory()) {
                                        expectedReportDir = expectedReportPath;
                                    } else {
                                        // Try without .html extension
                                        expectedReportDir = expectedReportPath.replace(/\.html$/, '');
                                    }
                                } catch {
                                    // Try without .html extension
                                    expectedReportDir = expectedReportPath.replace(/\.html$/, '');
                                }
                                // Check if the directory exists
                                try {
                                    const expectedStats = await stat(expectedReportDir);
                                    if (expectedStats.isDirectory()) {
                                        await compareDirectories(expectedReportDir, actualReportDir);
                                    } else {
                                        throw new Error(`Expected HTML report directory not found: ${expectedReportDir}`);
                                    }
                                } catch (error) {
                                    throw new Error(`Expected HTML report directory not found: ${expectedReportDir}: ${error}`);
                                }
                            } else {
                                // Other formats are single files
                                if (!reportData || !reportData.content) {
                                    throw new Error(`No ${format} report file found`);
                                }
                                const expectedContent = await readFile(join(fixturePath, expectedReportFile), 'utf-8');
                                assert.strictEqual(
                                    reportData.content,
                                    expectedContent,
                                    `${format} report mismatch (file: ${expectedReportFile})`
                                );
                            }
                        });
                    }
                }
            }
            
            // Get the first format's result for validations that only run once
            if (firstFormatResult === null) {
                throw new Error('No command results available');
            }
            
            // Use stdout result for return code/stderr checks (matching approval script behavior)
            // If stdout wasn't run, fall back to first format result
            const resultForValidation = stdoutResult || firstFormatResult;
            
            // Test: return code
            await fixtureTest.test('return code', async () => {
                const expectedReturnCode = await readExpectedFile(fixturePath, 'expected.returnCode');
                if (expectedReturnCode !== null) {
                    const expectedCode = parseInt(expectedReturnCode.trim(), 10);
                    assert.strictEqual(
                        resultForValidation!.code,
                        expectedCode,
                        `return code mismatch: expected ${expectedCode}, got ${resultForValidation!.code}`
                    );
                }
            });
            
            // Test: stderr
            await fixtureTest.test('stderr', async () => {
                const expectedStderr = await readExpectedFile(fixturePath, 'expected.stderr');
                if (expectedStderr !== null) {
                    assert.strictEqual(
                        stripAnsiCodes(resultForValidation!.stderr),
                        expectedStderr,
                        `stderr mismatch`
                    );
                }
            });
            
            // Test: stdout (only for stdout format)
            if (formatsToTest.includes('stdout')) {
                await fixtureTest.test('stdout', async () => {
                    const stdoutResult = commandResults.get('stdout')!;
                    const expectedStdout = await readExpectedFile(fixturePath, 'expected.stdout');
                    if (expectedStdout !== null) {
                        assert.strictEqual(
                            stripAnsiCodes(stdoutResult.stdout),
                            expectedStdout,
                            `stdout mismatch`
                        );
                    }
                });
            }
            
            // Test: instrumented project
            if (flags.hasExpectedInstrumentedProject) {
                await fixtureTest.test('instrumented project', async () => {
                    const expectedInstrumentedPath = join(fixturePath, 'expected-instrumented-project');
                    const actualInstrumentedPath = join(projectPath, 'elm-stuff', 'instrumented-project');
                    await compareDirectories(expectedInstrumentedPath, actualInstrumentedPath);
                });
            }
            
            // Test: coverage.json (using captured content from first format run)
            if (flags.hasExpectedCoverageJson) {
                await fixtureTest.test('coverage.json', async () => {
                    if (!capturedCoverageJson) {
                        throw new Error('coverage.json was not captured');
                    }
                    if (capturedCoverageJson.exists) {
                        const expectedCoverageContent = await readFile(join(fixturePath, 'expected-coverage.json'), 'utf-8');
                        const expectedCoverage = JSON.parse(expectedCoverageContent);
                        assert.deepStrictEqual(
                            capturedCoverageJson.content,
                            expectedCoverage,
                            `coverage.json mismatch`
                        );
                    } else {
                        // If coverage.json doesn't exist, expected should be empty {}
                        const expectedCoverageContent = await readFile(join(fixturePath, 'expected-coverage.json'), 'utf-8');
                        const expectedCoverage = JSON.parse(expectedCoverageContent);
                        assert.deepStrictEqual(
                            expectedCoverage,
                            {},
                            `Expected empty coverage.json but expected file contains: ${expectedCoverageContent}`
                        );
                    }
                });
            }
            
            // Test: metadata.json
            if (flags.hasExpectedMetadataJson) {
                await fixtureTest.test('metadata.json', async () => {
                    const actualMetadataPath = join(projectPath, 'elm-stuff', 'coverage-metadata.json');
                    const actualMetadataExists = await checkFileExists(actualMetadataPath);
                    if (actualMetadataExists) {
                        const expectedMetadataContent = await readFile(join(fixturePath, 'expected-metadata.json'), 'utf-8');
                        const actualMetadataContent = await readFile(actualMetadataPath, 'utf-8');
                        const expectedMetadata = JSON.parse(expectedMetadataContent);
                        const actualMetadata = JSON.parse(actualMetadataContent);
                        assert.deepStrictEqual(
                            actualMetadata,
                            expectedMetadata,
                            `coverage-metadata.json mismatch`
                        );
                    }
                });
            }
            
            for (const tempDir of tempDirectories) {
                try {
                    await rm(tempDir, { recursive: true, force: true });
                } catch {
                    // Ignore errors during cleanup
                }
            }
        });
    }
});
