import { spawn } from 'child_process';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { patch } from '../patch.js';

const args = process.argv.slice(2);

// Find the output JS file from arguments
let outputFile: string | null = null;
args.forEach((arg, i) => {
    if (arg === '--output') {
        const nextArg = args[i + 1];
        if (typeof nextArg === 'string') {
            outputFile = nextArg;
        }
    } else if (typeof arg === 'string' && arg.startsWith('--output=')) {
        outputFile = arg.slice('--output='.length);
    } else if (
        typeof arg === 'string' &&
        arg.endsWith('.js') &&
        !arg.startsWith('-')
    ) {
        outputFile = arg;
    }
});

// Execute elm compiler
const elmProcess = spawn('elm', args, {
    stdio: 'inherit', // Pass through stdin/stdout/stderr
});

// Wait for the process to complete
const exitCode = await new Promise<number>((resolve) => {
    elmProcess.on('close', (code) => {
        resolve(code ?? 0);
    });
});

if (exitCode !== 0) {
    process.exit(exitCode);
}

// If compilation succeeded, patch the output file
if (outputFile && existsSync(outputFile)) {
    const jsCode = readFileSync(outputFile, 'utf-8');
    // Determine if we're in a testing context (default to true for elm-test usage)
    // Can be overridden with ELM_COVERAGE_TESTING_CONTEXT=false environment variable
    const inTestingContext = process.env['ELM_COVERAGE_TESTING_CONTEXT'] !== 'false';
    const patched = patch(jsCode, { inTestingContext });
    writeFileSync(outputFile, patched);
}
