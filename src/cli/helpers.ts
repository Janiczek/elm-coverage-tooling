import { join } from 'path';
import { stat } from 'fs/promises';

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
