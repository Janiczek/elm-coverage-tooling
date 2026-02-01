import { resolve, join } from 'path';
import { readdir, stat, readFile, rm, writeFile, copyFile } from 'fs/promises';
import {
    runCommand,
    findExpectedReportFiles,
    stripAnsiCodes,
    copyDirectory,
    checkFileExists,
    findReportFiles,
    groupReportFilesByFormat,
    detectFixtureFlags,
    readCmdlineArgs,
    buildCommandArgs,
    getFormatExtension,
    getAllFormats,
} from '../test/helpers.ts';

const binaryPath = resolve(process.cwd(), 'bin', 'elm-coverage-test');
const fixturesPath = resolve(process.cwd(), 'test', 'elm-coverage-test-fixtures');

async function approveFixture(fixtureName: string): Promise<void> {
    const fixturePath = join(fixturesPath, fixtureName);
    const projectPath = join(fixturePath, 'project');

    // Check if fixture exists
    try {
        const fixtureStats = await stat(fixturePath);
        if (!fixtureStats.isDirectory()) {
            throw new Error(`Fixture path is not a directory: ${fixturePath}`);
        }
    } catch (error) {
        console.error(`Fixture not found: ${fixtureName}`);
        throw error;
    }

    // Check if project directory exists
    try {
        await stat(projectPath);
    } catch {
        console.error(`Project directory not found: ${projectPath}`);
        throw new Error(`Project directory not found: ${projectPath}`);
    }

    console.log(`Approving fixture: ${fixtureName}`);

    // Determine which flags to use based on existing expected files
    const flags = await detectFixtureFlags(fixturePath);
    const expectedReportFiles = await findExpectedReportFiles(fixturePath);
    const reportsByFormat = await groupReportFilesByFormat(fixturePath, expectedReportFiles);

    // Run ALL report formats to ensure all expected report files are created/updated
    const allFormats = getAllFormats();
    const formatsToTest = allFormats.map(f => f.format);

    // Read cmdline file if it exists
    const cmdlineArgs = await readCmdlineArgs(fixturePath);

    // Run the tool for each format and store results
    const commandResults = new Map<string, { stdout: string; stderr: string; code: number | null }>();
    const reportFilesCopied = new Set<string>();
    let firstFormatResult: { stdout: string; stderr: string; code: number | null } | null = null;
    let capturedCoverageJson: { content: any; exists: boolean } | null = null;

    for (const formatInfo of allFormats) {
        const { format, expectedFileName } = formatInfo;
        
        // Build command args
        const args = buildCommandArgs(format, flags, cmdlineArgs);

        console.log(`Running elm-coverage-test with format: ${format}...`);
        // Run the command from the project directory
        const result = await runCommand(binaryPath, args, { cwd: projectPath });
        commandResults.set(format, result);
        
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

        // Copy report file immediately after running this format (except stdout, handled later)
        if (format !== 'stdout') {
            const extension = getFormatExtension(format);

            if (extension) {
                // Find the actual report file(s)
                const elmStuffPath = join(projectPath, 'elm-stuff');
                const reportFiles = await findReportFiles(elmStuffPath, extension);

                if (format === 'html') {
                    // HTML reports are directories (coverage-report)
                    if (reportFiles.length > 0) {
                        const actualReportDir = reportFiles[0];
                        const expectedHtmlDir = join(fixturePath, expectedFileName);

                        // Remove existing expected-report-html directory if it exists
                        try {
                            await rm(expectedHtmlDir, { recursive: true, force: true });
                        } catch {
                            // Doesn't exist, which is fine
                        }

                        await copyDirectory(actualReportDir, expectedHtmlDir);
                        console.log(`✓ Copied HTML report to ${expectedFileName}/`);
                        reportFilesCopied.add(format);
                    } else {
                        console.warn(`⚠ No HTML report directory found for ${expectedFileName}`);
                    }
                } else {
                    // Other formats are single files
                    if (reportFiles.length > 0) {
                        const actualReportFile = reportFiles[0];
                        const expectedReportPath = join(fixturePath, expectedFileName);
                        await copyFile(actualReportFile, expectedReportPath);
                        console.log(`✓ Copied ${format} report to ${expectedFileName}`);
                        reportFilesCopied.add(format);
                    } else {
                        console.warn(`⚠ No ${format} report file found for ${expectedFileName}`);
                    }
                }
            }
        }
    }

    // Get the first format's result for outputs that only run once
    // (firstFormatResult was already captured in the loop above)
    if (firstFormatResult === null) {
        firstFormatResult = commandResults.get(formatsToTest[0])!;
    }

    // Copy stdout
    if (formatsToTest.includes('stdout')) {
        const stdoutResult = commandResults.get('stdout')!;
        const expectedStdoutPath = join(fixturePath, 'expected.stdout');
        await writeFile(expectedStdoutPath, stripAnsiCodes(stdoutResult.stdout), 'utf-8');
        console.log('✓ Copied stdout to expected.stdout');
    }

    // Copy stderr
    const expectedStderrPath = join(fixturePath, 'expected.stderr');
    await writeFile(expectedStderrPath, stripAnsiCodes(firstFormatResult.stderr), 'utf-8');
    console.log('✓ Copied stderr to expected.stderr');

    // Copy return code
    const expectedReturnCodePath = join(fixturePath, 'expected.returnCode');
    await writeFile(expectedReturnCodePath, String(firstFormatResult.code ?? 0), 'utf-8');
    console.log(`✓ Copied return code (${firstFormatResult.code}) to expected.returnCode`);

    // Copy instrumented project
    if (flags.hasExpectedInstrumentedProject) {
        const expectedInstrumentedProjectPath = join(fixturePath, 'expected-instrumented-project');
        const actualInstrumentedPath = join(projectPath, 'elm-stuff', 'instrumented-project');
        try {
            await stat(actualInstrumentedPath);
            // Remove existing expected-instrumented-project if it exists
            try {
                await rm(expectedInstrumentedProjectPath, { recursive: true, force: true });
            } catch {
                // Doesn't exist, which is fine
            }
            await copyDirectory(actualInstrumentedPath, expectedInstrumentedProjectPath);
            console.log('✓ Copied instrumented-project to expected-instrumented-project');
        } catch (error) {
            console.warn(`⚠ Could not copy instrumented-project: ${error}`);
        }
    }

    // Copy coverage.json (using captured content from first format run)
    if (flags.hasExpectedCoverageJson) {
        const expectedCoveragePath = join(fixturePath, 'expected-coverage.json');
        if (capturedCoverageJson && capturedCoverageJson.exists) {
            // Parse and re-stringify to normalize JSON formatting
            await writeFile(expectedCoveragePath, JSON.stringify(capturedCoverageJson.content, null, 2) + '\n', 'utf-8');
            console.log('✓ Copied coverage.json to expected-coverage.json');
        } else {
            // If coverage.json doesn't exist, write empty object
            await writeFile(expectedCoveragePath, '{}\n', 'utf-8');
            console.log('✓ Created empty expected-coverage.json (no coverage data generated)');
        }
    }

    // Copy metadata.json
    if (flags.hasExpectedMetadataJson) {
        const actualMetadataPath = join(projectPath, 'elm-stuff', 'coverage-metadata.json');
        const expectedMetadataPath = join(fixturePath, 'expected-metadata.json');
        try {
            const actualMetadataContent = await readFile(actualMetadataPath, 'utf-8');
            // Parse and re-stringify to normalize JSON formatting
            const actualMetadata = JSON.parse(actualMetadataContent);
            await writeFile(expectedMetadataPath, JSON.stringify(actualMetadata, null, 2) + '\n', 'utf-8');
            console.log('✓ Copied coverage-metadata.json to expected-metadata.json');
        } catch (error) {
            console.warn(`⚠ Could not copy metadata.json: ${error}`);
        }
    }

    // Report files are now copied immediately after each format run (see loop above)
    // This ensures each report is captured before the next format run potentially affects elm-stuff

    console.log(`\n✅ Successfully approved fixture: ${fixtureName}`);
}

async function getAllFixtures(): Promise<string[]> {
    const fixtures: string[] = [];
    try {
        const entries = await readdir(fixturesPath);
        for (const entry of entries) {
            const entryPath = join(fixturesPath, entry);
            const stats = await stat(entryPath);
            if (stats.isDirectory()) {
                // Check if it has a project subdirectory (to confirm it's a valid fixture)
                const projectPath = join(entryPath, 'project');
                try {
                    await stat(projectPath);
                    fixtures.push(entry);
                } catch {
                    // Not a valid fixture (no project directory)
                }
            }
        }
    } catch (error) {
        console.error(`Error reading fixtures directory: ${error}`);
        throw error;
    }
    return fixtures.sort();
}

async function main() {
    // Get fixture name from command line argument or environment variable
    const fixtureName = process.argv[2] || process.env.FIXTURE;
    
    if (!fixtureName) {
        // No fixture name provided, approve all fixtures
        console.log('No fixture name provided. Approving all fixtures...\n');
        const fixtures = await getAllFixtures();
        
        if (fixtures.length === 0) {
            console.error('No fixtures found in test/elm-coverage-test-fixtures');
            process.exit(1);
        }
        
        console.log(`Found ${fixtures.length} fixture(s) to approve:\n`);
        
        let successCount = 0;
        let failureCount = 0;
        
        for (const fixture of fixtures) {
            try {
                await approveFixture(fixture);
                successCount++;
            } catch (error) {
                console.error(`\n❌ Failed to approve fixture: ${fixture}`);
                console.error(`Error: ${error}`);
                failureCount++;
            }
            console.log(''); // Add blank line between fixtures
        }
        
        console.log(`\n📊 Summary: ${successCount} succeeded, ${failureCount} failed`);
        
        if (failureCount > 0) {
            process.exit(1);
        }
    } else {
        // Single fixture provided
        try {
            await approveFixture(fixtureName);
        } catch (error) {
            console.error(`Error approving fixture: ${error}`);
            process.exit(1);
        }
    }
}

main().catch((error) => {
    console.error('Error:', error);
    process.exit(1);
});
