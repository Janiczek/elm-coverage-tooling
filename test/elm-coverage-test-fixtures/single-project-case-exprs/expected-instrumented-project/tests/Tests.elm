module Tests exposing (suite)

import CaseExprs
import Expect
import Test exposing (Test, test)

suite : Test
suite =
    Test.describe "CaseExprs"
        [ test "twoBranches Just" <|
            \_ ->
                CaseExprs.twoBranches (Just 5)
                    |> Expect.equal 10
        , test "twoBranches Nothing" <|
            \_ ->
                CaseExprs.twoBranches Nothing
                    |> Expect.equal 0
        , test "threeBranches Ok" <|
            \_ ->
                CaseExprs.threeBranches (Ok 42)
                    |> Expect.equal "Success: 42"
        , test "threeBranches Err error" <|
            \_ ->
                CaseExprs.threeBranches (Err "error")
                    |> Expect.equal "Error occurred"
        , test "threeBranches Err other" <|
            \_ ->
                CaseExprs.threeBranches (Err "something")
                    |> Expect.equal "Other error: something"
        , test "fourBranches 0" <|
            \_ ->
                CaseExprs.fourBranches 0
                    |> Expect.equal "zero"
        , test "fourBranches 1" <|
            \_ ->
                CaseExprs.fourBranches 1
                    |> Expect.equal "one"
        , test "nestedCase Just Ok" <|
            \_ ->
                CaseExprs.nestedCase (Just (Ok 10))
                    |> Expect.equal "Got value: 10"
        , test "nestedCase Just Err" <|
            \_ ->
                CaseExprs.nestedCase (Just (Err "fail"))
                    |> Expect.equal "Got error: fail"
        , test "nestedCase Nothing" <|
            \_ ->
                CaseExprs.nestedCase Nothing
                    |> Expect.equal "No result"
        , test "partiallyCoveredCase 0" <|
            \_ ->
                CaseExprs.partiallyCoveredCase 0
                    |> Expect.equal "zero"
        , test "partiallyCoveredCase 1" <|
            \_ ->
                CaseExprs.partiallyCoveredCase 1
                    |> Expect.equal "one"
        -- Note: Not testing all branches (2, 3, _) to create partial coverage
        ]
