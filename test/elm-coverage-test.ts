import test from 'node:test';
import assert from 'node:assert';
import { resolve, join } from 'path';
import { readdir, stat, readFile } from 'fs/promises';
import {
    runCommand,
    readExpectedFile,
    findExpectedReportFiles,
    compareDirectories,
    stripAnsiCodes,
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
            
            const firstFormat = formatsToTest[0];
            
            // Read cmdline file if it exists
            const cmdlineArgs = await readCmdlineArgs(fixturePath);
            
            // Test: return code — run the tool and assert (duration includes the run)
            await fixtureTest.test('return code', async () => {
                const args = buildCommandArgs(firstFormat, flags, cmdlineArgs);
                const result = await runCommand(binaryPath, args, { cwd: projectPath });
                const expectedReturnCode = await readExpectedFile(fixturePath, 'expected.returnCode');
                if (expectedReturnCode !== null) {
                    const expectedCode = parseInt(expectedReturnCode.trim(), 10);
                    assert.strictEqual(
                        result.code,
                        expectedCode,
                        `return code mismatch: expected ${expectedCode}, got ${result.code}`
                    );
                }
            });
            
            // Test: stderr — run the tool and assert
            await fixtureTest.test('stderr', async () => {
                const args = buildCommandArgs(firstFormat, flags, cmdlineArgs);
                const result = await runCommand(binaryPath, args, { cwd: projectPath });
                const expectedStderr = await readExpectedFile(fixturePath, 'expected.stderr');
                if (expectedStderr !== null) {
                    assert.strictEqual(
                        stripAnsiCodes(result.stderr),
                        expectedStderr,
                        `stderr mismatch`
                    );
                }
            });
            
            // Test: stdout — run the tool with stdout format and assert
            if (formatsToTest.includes('stdout')) {
                await fixtureTest.test('stdout', async () => {
                    const args = buildCommandArgs('stdout', flags, cmdlineArgs);
                    const result = await runCommand(binaryPath, args, { cwd: projectPath });
                    const expectedStdout = await readExpectedFile(fixturePath, 'expected.stdout');
                    if (expectedStdout !== null) {
                        assert.strictEqual(
                            stripAnsiCodes(result.stdout),
                            expectedStdout,
                            `stdout mismatch`
                        );
                    }
                });
            }
            
            // Tests for each report format — each runs the tool, captures report, then asserts
            for (const format of formatsToTest) {
                if (format === 'stdout') continue;
                const formatReportFiles = reportsByFormat.get(format) || [];
                const extension = getFormatExtension(format);
                if (!extension) continue;
                
                for (const expectedReportFile of formatReportFiles) {
                    const formatName = format.toUpperCase();
                    const testName = formatReportFiles.length > 1 
                        ? `report: ${formatName} (${expectedReportFile})`
                        : `report: ${formatName}`;
                    await fixtureTest.test(testName, async () => {
                        const args = buildCommandArgs(format, flags, cmdlineArgs);
                        await runCommand(binaryPath, args, { cwd: projectPath });
                        const elmStuffPath = join(projectPath, 'elm-stuff');
                        const reportFiles = await findReportFiles(elmStuffPath, extension);
                        
                        if (format === 'html') {
                            if (reportFiles.length === 0) {
                                throw new Error(`No HTML report directory found`);
                            }
                            const actualReportDir = reportFiles[0];
                            const expectedReportPath = join(fixturePath, expectedReportFile);
                            let expectedReportDir = expectedReportPath;
                            try {
                                const expectedStats = await stat(expectedReportPath);
                                if (!expectedStats.isDirectory()) {
                                    expectedReportDir = expectedReportPath.replace(/\.html$/, '');
                                }
                            } catch {
                                expectedReportDir = expectedReportPath.replace(/\.html$/, '');
                            }
                            const expectedDirStats = await stat(expectedReportDir);
                            if (!expectedDirStats.isDirectory()) {
                                throw new Error(`Expected HTML report directory not found: ${expectedReportDir}`);
                            }
                            await compareDirectories(expectedReportDir, actualReportDir);
                        } else {
                            if (reportFiles.length === 0) {
                                throw new Error(`No ${format} report file found`);
                            }
                            const actualContent = await readFile(reportFiles[0], 'utf-8');
                            const expectedContent = await readFile(join(fixturePath, expectedReportFile), 'utf-8');
                            assert.strictEqual(
                                actualContent,
                                expectedContent,
                                `${format} report mismatch (file: ${expectedReportFile})`
                            );
                        }
                    });
                }
            }
            
            // Test: instrumented project — run the tool then compare
            if (flags.hasExpectedInstrumentedProject) {
                await fixtureTest.test('instrumented project', async () => {
                    const args = buildCommandArgs(firstFormat, flags, cmdlineArgs);
                    await runCommand(binaryPath, args, { cwd: projectPath });
                    const expectedInstrumentedPath = join(fixturePath, 'expected-instrumented-project');
                    const actualInstrumentedPath = join(projectPath, 'elm-stuff', 'instrumented-project');
                    await compareDirectories(expectedInstrumentedPath, actualInstrumentedPath);
                });
            }
            
            // Test: coverage.json — run the tool then read and assert
            if (flags.hasExpectedCoverageJson) {
                await fixtureTest.test('coverage.json', async () => {
                    const args = buildCommandArgs(firstFormat, flags, cmdlineArgs);
                    await runCommand(binaryPath, args, { cwd: projectPath });
                    const actualCoveragePath = join(projectPath, 'elm-stuff', 'coverage.json');
                    const actualCoverageExists = await checkFileExists(actualCoveragePath);
                    const expectedCoverageContent = await readFile(join(fixturePath, 'expected-coverage.json'), 'utf-8');
                    const expectedCoverage = JSON.parse(expectedCoverageContent);
                    if (actualCoverageExists) {
                        const actualCoverageContent = await readFile(actualCoveragePath, 'utf-8');
                        const actualCoverage = JSON.parse(actualCoverageContent);
                        assert.deepStrictEqual(
                            actualCoverage,
                            expectedCoverage,
                            `coverage.json mismatch`
                        );
                    } else {
                        assert.deepStrictEqual(
                            expectedCoverage,
                            {},
                            `Expected empty coverage.json but expected file contains: ${expectedCoverageContent}`
                        );
                    }
                });
            }
            
            // Test: metadata.json — run the tool then read and assert
            if (flags.hasExpectedMetadataJson) {
                await fixtureTest.test('metadata.json', async () => {
                    const args = buildCommandArgs(firstFormat, flags, cmdlineArgs);
                    await runCommand(binaryPath, args, { cwd: projectPath });
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
        });
    }
});
