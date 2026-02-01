module Tests exposing (suite)

import AndExprs
import Expect
import Test exposing (Test, test)

suite : Test
suite =
    Test.describe "AndExprs"
        [ test "twoAnd both true" <|
            \_ ->
                AndExprs.twoAnd True True
                    |> Expect.equal True
        , test "twoAnd first false" <|
            \_ ->
                AndExprs.twoAnd False True
                    |> Expect.equal False
        , test "twoAnd second false" <|
            \_ ->
                AndExprs.twoAnd True False
                    |> Expect.equal False
        , test "threeAnd all true" <|
            \_ ->
                AndExprs.threeAnd True True True
                    |> Expect.equal True
        , test "threeAnd first false" <|
            \_ ->
                AndExprs.threeAnd False True True
                    |> Expect.equal False
        -- Note: Not testing threeAnd with b=False to create partial coverage
        , test "threeAnd third false" <|
            \_ ->
                AndExprs.threeAnd True True False
                    |> Expect.equal False
        -- Note: fourAnd is fully uncovered (no tests)
        , test "nestedAnd all true" <|
            \_ ->
                AndExprs.nestedAnd True True True
                    |> Expect.equal True
        , test "partiallyCoveredAnd first false" <|
            \_ ->
                AndExprs.partiallyCoveredAnd False True True
                    |> Expect.equal False
        -- Note: Not testing all short-circuit paths to create partial coverage
        ]
