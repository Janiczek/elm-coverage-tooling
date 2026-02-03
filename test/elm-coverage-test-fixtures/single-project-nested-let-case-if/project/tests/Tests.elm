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
        , test "listWithCaseIfLet Just True" <|
            \_ ->
                NestedLetCaseIf.listWithCaseIfLet (Just 5) True
                    |> Expect.equal [ 5, 1, 1 ]
        , test "listWithCaseIfLet Nothing False" <|
            \_ ->
                NestedLetCaseIf.listWithCaseIfLet Nothing False
                    |> Expect.equal [ 0, 2, 1 ]
        , test "tuple3WithCaseIfLet Just True" <|
            \_ ->
                NestedLetCaseIf.tuple3WithCaseIfLet (Just 5) True
                    |> Expect.equal ( 5, 1, 1 )
        , test "tuple3WithCaseIfLet Nothing False" <|
            \_ ->
                NestedLetCaseIf.tuple3WithCaseIfLet Nothing False
                    |> Expect.equal ( 0, 2, 1 )
        , test "tupleWithBareVar" <|
            \_ ->
                NestedLetCaseIf.tupleWithBareVar 7
                    |> Expect.equal ( 42, 7 )
        , test "recordWithCaseIfLet Just True" <|
            \_ ->
                NestedLetCaseIf.recordWithCaseIfLet (Just 5) True
                    |> Expect.equal { a = 5, b = 1, c = 1 }
        , test "recordWithCaseIfLet Nothing False" <|
            \_ ->
                NestedLetCaseIf.recordWithCaseIfLet Nothing False
                    |> Expect.equal { a = 0, b = 2, c = 1 }
        , test "recordUpdateWithCaseIfLet Just True" <|
            \_ ->
                NestedLetCaseIf.recordUpdateWithCaseIfLet { a = 0, b = 0, c = 0 } (Just 5) True
                    |> Expect.equal { a = 5, b = 1, c = 1 }
        , test "recordUpdateWithCaseIfLet Nothing False" <|
            \_ ->
                NestedLetCaseIf.recordUpdateWithCaseIfLet { a = 0, b = 0, c = 0 } Nothing False
                    |> Expect.equal { a = 0, b = 2, c = 1 }
        , test "recordWithPlainFields" <|
            \_ ->
                NestedLetCaseIf.recordWithPlainFields 7
                    |> Expect.equal { a = 7, b = 8 }
        , test "parenthesizedCase Just" <|
            \_ ->
                NestedLetCaseIf.parenthesizedCase (Just 42)
                    |> Expect.equal 42
        , test "parenthesizedCase Nothing" <|
            \_ ->
                NestedLetCaseIf.parenthesizedCase Nothing
                    |> Expect.equal 0
        , test "caseCasePipe" <|
            \_ ->
                NestedLetCaseIf.caseCasePipe True (Just 1) (Just 2) False
                    |> Expect.equal ( 1, 2 )
        , test "ifIfPipe" <|
            \_ ->
                NestedLetCaseIf.ifIfPipe True False True False
                    |> Expect.equal ( 1, 3 )
        , test "letLetPipe" <|
            \_ ->
                NestedLetCaseIf.letLetPipe
                    |> Expect.equal ( 1, 2 )
        -- Note: Not testing all branches to create partial coverage
        ]
