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
            coverageMetadata: new Map([
                [154242004, {
                    declarationName: 'a',
                    moduleName: 'A',
                    moduleFilePath: 'A.elm',
                    range: [[5, 5], [5, 8]],
                    category: 'declaration'
                }]
            ]),
            instrumentedElmSourceCode: `
module A exposing (a)

import Test.Coverage


a : Int
a =
    let
        _ =
            Test.Coverage.track 154242004
    in
    123
`,
            contentHash: 4167962317
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
            coverageMetadata: new Map([
                [1762450980, {
                    declarationName: 'a',
                    moduleName: 'A.B.C',
                    moduleFilePath: 'A/B/C.elm',
                    range: [[5, 5], [5, 8]],
                    category: 'declaration'
                }]
            ]),
            instrumentedElmSourceCode: `
module A.B.C exposing (a)

import Test.Coverage


a : Int
a =
    let
        _ =
            Test.Coverage.track 1762450980
    in
    123
`,
            contentHash: 3521263262
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
    },
    {
        name: 'import is added when not present',
        input: `
module A exposing (a)

a : Int
a =
    123
`,
        output: {
            coverageMetadata: new Map([
                [154242004, {
                    declarationName: 'a',
                    moduleName: 'A',
                    moduleFilePath: 'A.elm',
                    range: [[5, 5], [5, 8]],
                    category: 'declaration'
                }]
            ]),
            instrumentedElmSourceCode: `
module A exposing (a)

import Test.Coverage


a : Int
a =
    let
        _ =
            Test.Coverage.track 154242004
    in
    123
`,
            contentHash: 4167962317
        }
    },
    {
        name: 'import is not duplicated if already present',
        input: `
module A exposing (a)

import Test.Coverage

a : Int
a =
    123
`,
        output: {
            coverageMetadata: new Map([
                [154242004, {
                    declarationName: 'a',
                    moduleName: 'A',
                    moduleFilePath: 'A.elm',
                    range: [[7, 5], [7, 8]],
                    category: 'declaration'
                }]
            ]),
            instrumentedElmSourceCode: `
module A exposing (a)

import Test.Coverage


a : Int
a =
    let
        _ =
            Test.Coverage.track 154242004
    in
    123
`,
            contentHash: 4246185318
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