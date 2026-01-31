import test from 'node:test';
import assert from 'node:assert';
import { instrument } from '../src/instrument.ts';

test('instrument', async (t) => {
    await t.test('simple constant', async () => {
        const output = await instrument('module A exposing (a)\n\na : Int\na = 123');
        assert.deepStrictEqual(output,
            {
                coverageMetadata: {
                    '154242004': {
                        declarationName: 'a',
                        moduleName: 'A',
                        range: [[4, 5], [4, 8]]
                    }
                },
                instrumentedElmSourceCode: `module A exposing (a)


a : Int
a =
    let
        _ =
            Test.Coverage.track 154242004
    in
    123
`

            }
        );
    });

    await t.test('compound module name', async () => {
        const output = await instrument('module A.B.C exposing (a)\n\na : Int\na = 123');
        assert.deepStrictEqual(output,
            {
                coverageMetadata: {
                    '1762450980': {
                        declarationName: 'a',
                        moduleName: 'A.B.C',
                        range: [[4, 5], [4, 8]]
                    }
                },
                instrumentedElmSourceCode: `module A.B.C exposing (a)


a : Int
a =
    let
        _ =
            Test.Coverage.track 1762450980
    in
    123
`
            });
    });

    await t.test('error', async () => {
        const output = await instrument('module A exposing (a)\n\na : { invalid');
        assert.deepStrictEqual(output, { error: "Can't parse the Elm code." });
    });
});