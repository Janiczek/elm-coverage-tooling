module Tests exposing (suite)

import NestedLetCaseIf
import Expect
import Test exposing (Test, test)

suite : Test
suite =
    Test.describe "NestedLetCaseIf"
        [ test "nestedCaseOf Just Ok 0" <|
            \_ ->
                NestedLetCaseIf.nestedCaseOf (Just (Ok 0))
                    |> Expect.equal "zero"
        , test "nestedCaseOf Just Ok 1" <|
            \_ ->
                NestedLetCaseIf.nestedCaseOf (Just (Ok 1))
                    |> Expect.equal "one"
        , test "nestedCaseOf Just Ok other" <|
            \_ ->
                NestedLetCaseIf.nestedCaseOf (Just (Ok 42))
                    |> Expect.equal "other"
        , test "nestedCaseOf Just Err" <|
            \_ ->
                NestedLetCaseIf.nestedCaseOf (Just (Err "fail"))
                    |> Expect.equal "error: fail"
        , test "nestedCaseOf Nothing" <|
            \_ ->
                NestedLetCaseIf.nestedCaseOf Nothing
                    |> Expect.equal "nothing"
        , test "caseInLet Just" <|
            \_ ->
                NestedLetCaseIf.caseInLet (Just 5) 3
                    |> Expect.equal 8
        , test "caseInLet Nothing" <|
            \_ ->
                NestedLetCaseIf.caseInLet Nothing 3
                    |> Expect.equal 3
        , test "ifInLet true" <|
            \_ ->
                NestedLetCaseIf.ifInLet True 5
                    |> Expect.equal 10
        , test "ifInLet false" <|
            \_ ->
                NestedLetCaseIf.ifInLet False 5
                    |> Expect.equal 5
        , test "complexNested Just 0 True" <|
            \_ ->
                NestedLetCaseIf.complexNested (Just 0) True
                    |> Expect.equal "zero with flag"
        , test "complexNested Just 1 True" <|
            \_ ->
                NestedLetCaseIf.complexNested (Just 1) True
                    |> Expect.equal "one with flag"
        , test "complexNested Just 0 False" <|
            \_ ->
                NestedLetCaseIf.complexNested (Just 0) False
                    |> Expect.equal "zero without flag"
        , test "complexNested Just 1 False" <|
            \_ ->
                NestedLetCaseIf.complexNested (Just 1) False
                    |> Expect.equal "one without flag"
        , test "complexNested Nothing True" <|
            \_ ->
                NestedLetCaseIf.complexNested Nothing True
                    |> Expect.equal "zero with flag"
        -- Note: Not testing all branches to create partial coverage
        ]
