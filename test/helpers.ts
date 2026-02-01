import { spawn } from 'child_process';

export function runCommand(
    command: string,
    args: string[]
): Promise<{ stdout: string; stderr: string; code: number | null }> {
    return new Promise((resolve) => {
        const child = spawn(command, args, {
            cwd: process.cwd(),
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
