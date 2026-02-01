module Tests exposing (suite)

import Expect
import IfExprs
import Test exposing (Test, test)

suite : Test
suite =
    Test.describe "IfExprs"
        [ test "singleIf positive" <|
            \_ ->
                IfExprs.singleIf 5
                    |> Expect.equal "positive"
        , test "singleIf negative" <|
            \_ ->
                IfExprs.singleIf -3
                    |> Expect.equal "non-positive"
        , test "nestedIfs both positive" <|
            \_ ->
                IfExprs.nestedIfs 5 10
                    |> Expect.equal "both positive"
        , test "nestedIfs x positive y not" <|
            \_ ->
                IfExprs.nestedIfs 5 -3
                    |> Expect.equal "x positive, y not"
        , test "complexIf all positive" <|
            \_ ->
                IfExprs.complexIf 1 2 3
                    |> Expect.equal "all positive"
        , test "partiallyCoveredIf both true" <|
            \_ ->
                IfExprs.partiallyCoveredIf True True
                    |> Expect.equal "both true"
        -- Note: Not testing all branches to create partial coverage
        ]
