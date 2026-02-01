import test from 'node:test';
import assert from 'node:assert';
import { resolve } from 'path';
import { runCommand } from './helpers';

const binaryPath = resolve(process.cwd(), 'bin', 'elm-coverage-test');

test('elm-coverage-test CLI', async (t) => {
    await t.test('shows usage when run without arguments', async () => {
        const { stdout, stderr } = await runCommand(binaryPath, []);
        
        assert(
            stderr.includes('--runner') && stderr.includes('--coverage-format'),
            `Expected help output in stderr with --runner and --coverage-format, but stderr was: ${stderr}`
        );
        
        assert.strictEqual(stdout, '', `Expected stdout to be empty, but got: ${stdout}`);
    });
});
