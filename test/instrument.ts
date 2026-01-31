import test from 'node:test';
import assert from 'node:assert';
import { instrument, type InstrumentOutput } from '../src/instrument.ts';

type TestCase = {
    name: string;
    input: string;
    output: InstrumentOutput;
};

const testCases: TestCase[] = [
    {
        name: 'simple constant',
        input: `
module A exposing (a)

a : Int
a =
    123
`,
        output: {
            coverageMetadata: {
                '154242004': {
                    declarationName: 'a',
                    moduleName: 'A',
                    range: [[5, 5], [5, 8]]
                }
            },
            instrumentedElmSourceCode: `
module A exposing (a)


a : Int
a =
    let
        _ =
            Test.Coverage.track 154242004
    in
    123
`
        }
    },
    {
        name: 'compound module name',
        input: `
module A.B.C exposing (a)

a : Int
a =
    123
`,
        output: {
            coverageMetadata: {
                '1762450980': {
                    declarationName: 'a',
                    moduleName: 'A.B.C',
                    range: [[5, 5], [5, 8]]
                }
            },
            instrumentedElmSourceCode: `
module A.B.C exposing (a)


a : Int
a =
    let
        _ =
            Test.Coverage.track 1762450980
    in
    123
`
        }
    },
    {
        name: 'parse error',
        input: `
module A exposing (a)

a : Int
a =
    { invalid
`,
        output: {
            error: "Can't parse the Elm code."
        }
    }
];

function trimSuccess(output: InstrumentOutput): InstrumentOutput {
    if ('error' in output) {
        return output;
    }
    return {
        ...output,
        instrumentedElmSourceCode: output.instrumentedElmSourceCode.trim()
    };
}

function testCase(tc: TestCase) {
    return async () => {
        const output = await instrument(tc.input.trim());
        assert.deepStrictEqual(
            trimSuccess(output),
            trimSuccess(tc.output)
        );
    };
}

test('instrument', async (t) => {
    for (const tc of testCases) {
        await t.test(tc.name, testCase(tc));
    }
});