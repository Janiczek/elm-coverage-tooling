import { join } from 'path';
import { stat, mkdir, writeFile } from 'fs/promises';

/**
 * Checks if the current directory (or specified directory) is the root of an Elm project
 * by verifying that elm.json exists.
 * 
 * @param projectDir - The directory to check (defaults to process.cwd())
 * @throws If elm.json is not found, exits the process with code 1
 */
export async function ensureElmProjectRoot(projectDir: string = process.cwd()): Promise<void> {
    const elmJsonPath = join(projectDir, 'elm.json');
    try {
        await stat(elmJsonPath);
    } catch (error) {
        console.error(`Error: elm.json not found in ${projectDir}`);
        process.exit(1);
    }
}

/**
 * Creates the Test.Coverage dummy module in the specified directory.
 * This stub module is needed for instrumented code to compile.
 * The JavaScript patching will replace the no-op implementation with actual tracking.
 * 
 * @param tempDir - The temporary project directory where the module should be created
 * @param sourceDir - The source directory (relative to tempDir) where the module should be created
 */
export async function createTestCoverageModule(tempDir: string, sourceDir: string): Promise<void> {
    const testCoverageDir = join(tempDir, sourceDir, 'Test');
    await mkdir(testCoverageDir, { recursive: true });
    const testCoverageModule = `module Test.Coverage exposing (track)

{-| Stub module for coverage tracking.
The actual implementation is provided via JavaScript patching.
-}
track : Int -> ()
track _ =
    ()
`;
    await writeFile(join(tempDir, sourceDir, 'Test', 'Coverage.elm'), testCoverageModule);
}

