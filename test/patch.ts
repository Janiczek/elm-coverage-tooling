import test from 'node:test';
import assert from 'node:assert';
import { patch } from '../src/patch.ts';

function countOccurrences(text: string, pattern: string): number {
    const regex = new RegExp(pattern.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
    const matches = text.match(regex);
    return matches ? matches.length : 0;
}

test('patch', async (t) => {
    await t.test('non-testing context (minimal patch)', () => {
        const input = `
var someOtherCode = function() {
    return 42;
};

var $author$project$Test$Coverage$track = function (pointId) {
    return _Utils_Tuple0;
};
`;

        const output = patch(input, { inTestingContext: false });

        assert.strictEqual(countOccurrences(input,  'globalThis.__elm_line_coverage'), 0);
        assert.strictEqual(countOccurrences(output, 'globalThis.__elm_line_coverage'), 3);

        assert.strictEqual(countOccurrences(input,  'JSON.stringify(globalThis.__elm_line_coverage)'), 0);
        assert.strictEqual(countOccurrences(output, 'JSON.stringify(globalThis.__elm_line_coverage)'), 0);

        assert.strictEqual(countOccurrences(input,  'var $author$project$Test$Coverage$track'), 1);
        assert.strictEqual(countOccurrences(output, 'var $author$project$Test$Coverage$track'), 1);
    });

    await t.test('testing context (full patch)', () => {
        const input = `
var someOtherCode = function() {
    return 42;
};

var $author$project$Test$Coverage$track = function (pointId) {
    return _Utils_Tuple0;
};
`;

        const output = patch(input, { inTestingContext: true });

        assert.strictEqual(countOccurrences(input, 'globalThis.__elm_line_coverage'), 0);
        assert.strictEqual(countOccurrences(output, 'globalThis.__elm_line_coverage'), 4);

        assert.strictEqual(countOccurrences(input, 'JSON.stringify(globalThis.__elm_line_coverage)'), 0);
        assert.strictEqual(countOccurrences(output, 'JSON.stringify(globalThis.__elm_line_coverage)'), 1);

        assert.strictEqual(countOccurrences(input, 'var $author$project$Test$Coverage$track'), 1);
        assert.strictEqual(countOccurrences(output, 'var $author$project$Test$Coverage$track'), 1);
    });
});
