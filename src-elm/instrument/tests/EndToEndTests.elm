module EndToEndTests exposing (suite)

import Dict
import Expect
import Main
import Test exposing (Test)


type alias TestCase =
    { name : String
    , input : String
    , output : Main.Output
    }


suite : Test
suite =
    Test.describe "End to end tests"
        ([ { name = "simple constant"
           , input = """
module A exposing (a)

a : Int
a =
    123
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module A exposing (a)

import Test.Coverage


a : Int
a =
    let
        _ =
            Test.Coverage.track 154242004
    in
    123
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 154242004
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 5, column = 8 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 4167962317
                    }
           }
        ,  { name = "compound module name"
           , input = """
module A.B.C exposing (a)

a : Int
a =
    123
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module A.B.C exposing (a)

import Test.Coverage


a : Int
a =
    let
        _ =
            Test.Coverage.track 1762450980
    in
    123
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 1762450980
                              , { moduleName = "A.B.C"
                                , moduleFilePath = "A/B/C.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 5, column = 8 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 3521263262
                    }
           }
         , { name = "function with unit parameter"
           , input = """
module A exposing (a)

a : () -> Int
a () =
    123
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module A exposing (a)

import Test.Coverage


a : () -> Int
a () =
    let
        _ =
            Test.Coverage.track 154242004
    in
    123
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 154242004
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 5, column = 8 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 3074062920
                    }
           }
         , { name = "addition expression"
           , input = """
module A exposing (a)

a : Int
a =
    1 + 2
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module A exposing (a)

import Test.Coverage


a : Int
a =
    let
        _ =
            Test.Coverage.track 154242004
    in
    1 + 2
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 154242004
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 5, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 3759383353
                    }
           }
         , { name = "if expression"
           , input = """
module A exposing (a)

a : Int
a =
    if True && False then
        5
    else
        6
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module A exposing (a)

import Test.Coverage


a : Int
a =
    if
        let
            _ =
                Test.Coverage.track 107558697
        in
        (let
            _ =
                Test.Coverage.track 154242004
         in
         True
        )
            && (let
                    _ =
                        Test.Coverage.track 1751612961
                in
                False
               )
    then
        let
            _ =
                Test.Coverage.track 1885435985
        in
        5

    else
        let
            _ =
                Test.Coverage.track 434548591
        in
        6
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 107558697
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 8 }, end = { row = 5, column = 21 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 154242004
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 8 }, end = { row = 5, column = 12 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1751612961
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 16 }, end = { row = 5, column = 21 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1885435985
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 6, column = 9 }, end = { row = 6, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 434548591
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 8, column = 9 }, end = { row = 8, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            ]
                    , contentHash = 230325722
                    }
           }
         , { name = "case expression"
           , input = """
module A exposing (a)

a : Int
a =
    case 2 of
        1 -> 100
        2 -> 200
        _  -> 0
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module A exposing (a)

import Test.Coverage


a : Int
a =
    case
        let
            _ =
                Test.Coverage.track 154242004
        in
        2
    of
        1 ->
            let
                _ =
                    Test.Coverage.track 1751612961
            in
            100

        2 ->
            let
                _ =
                    Test.Coverage.track 107558697
            in
            200

        _ ->
            let
                _ =
                    Test.Coverage.track 1885435985
            in
            0
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 107558697
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 7, column = 14 }, end = { row = 7, column = 17 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 154242004
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 10 }, end = { row = 5, column = 11 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1751612961
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 6, column = 14 }, end = { row = 6, column = 17 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1885435985
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 8, column = 15 }, end = { row = 8, column = 16 } }
                                , category = "case-branch"
                                }
                              )
                            ]
                    , contentHash = 510858290
                    }
           }
         , { name = "multiple declarations"
           , input = """
module A exposing (a, b)

a : Int
a =
    42

b : String
b =
    "hello"
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module A exposing (a, b)

import Test.Coverage


b : String
b =
    let
        _ =
            Test.Coverage.track 1751612961
    in
    "hello"


a : Int
a =
    let
        _ =
            Test.Coverage.track 154242004
    in
    42

"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 154242004
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 5, column = 7 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1751612961
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "b"
                                , range = { start = { row = 9, column = 5 }, end = { row = 9, column = 12 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 3470614315
                    }
           }
         , { name = "or expressions in if statements"
           , input = """
module A exposing (a)

a b c =
    if b == 1 || c == 1 then
        ()
    else if b == 2 || c == 2 then
        ()
    else
        ()
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module A exposing (a)

import Test.Coverage


a b c =
    if
        let
            _ =
                Test.Coverage.track 107558697
        in
        (let
            _ =
                Test.Coverage.track 154242004
         in
         b == 1
        )
            || (let
                    _ =
                        Test.Coverage.track 1751612961
                in
                c == 1
               )
    then
        let
            _ =
                Test.Coverage.track 1885435985
        in
        ()

    else if
        let
            _ =
                Test.Coverage.track 1045688889
        in
        (let
            _ =
                Test.Coverage.track 434548591
         in
         b == 2
        )
            || (let
                    _ =
                        Test.Coverage.track 1004572879
                in
                c == 2
               )
    then
        let
            _ =
                Test.Coverage.track 1642697927
        in
        ()

    else
        let
            _ =
                Test.Coverage.track 1405027598
        in
        ()

"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 107558697
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 4, column = 8 }, end = { row = 4, column = 24 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 154242004
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 4, column = 8 }, end = { row = 4, column = 14 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 434548591
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 6, column = 13 }, end = { row = 6, column = 19 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1004572879
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 6, column = 23 }, end = { row = 6, column = 29 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1045688889
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 6, column = 13 }, end = { row = 6, column = 29 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1751612961
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 4, column = 18 }, end = { row = 4, column = 24 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1885435985
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 9 }, end = { row = 5, column = 11 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1642697927
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 7, column = 9 }, end = { row = 7, column = 11 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1885435985
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 9 }, end = { row = 5, column = 11 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1405027598
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 9, column = 9 }, end = { row = 9, column = 11 } }
                                , category = "if-branch"
                                }
                              )
                            ]
                    , contentHash = 4057747903
                    }
           }
         , { name = "parse error"
           , input = """
module A exposing (a)

a : Int
a =
    { invalid
"""
           , output =
                Err "Can't parse the Elm code."
           }
         , { name = "nestedCaseOf"
           , input = """
module NestedLetCaseIf exposing (nestedCaseOf)

nestedCaseOf : Maybe (Result String Int) -> String
nestedCaseOf maybeResult =
    case maybeResult of
        Just result ->
            case result of
                Ok value ->
                    case value of
                        0 ->
                            "zero"
                        1 ->
                            "one"
                        _ ->
                            "other"
                Err msg ->
                    "error: " ++ msg
        Nothing ->
            "nothing"
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (nestedCaseOf)

import Test.Coverage


nestedCaseOf : Maybe (Result String Int) -> String
nestedCaseOf maybeResult =
    case
        let
            _ =
                Test.Coverage.track 357133973
        in
        maybeResult
    of
        Just result ->
            case
                let
                    _ =
                        Test.Coverage.track 1615377089
                in
                result
            of
                Ok value ->
                    case
                        let
                            _ =
                                Test.Coverage.track 353199476
                        in
                        value
                    of
                        0 ->
                            let
                                _ =
                                    Test.Coverage.track 2069063037
                            in
                            "zero"

                        1 ->
                            let
                                _ =
                                    Test.Coverage.track 1161055252
                            in
                            "one"

                        _ ->
                            let
                                _ =
                                    Test.Coverage.track 1337164990
                            in
                            "other"

                Err msg ->
                    let
                        _ =
                            Test.Coverage.track 2130358651
                    in
                    "error: " ++ msg

        Nothing ->
            let
                _ =
                    Test.Coverage.track 960691989
            in
            "nothing"
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 9, column = 26 }, end = { row = 9, column = 31 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 5, column = 10 }, end = { row = 5, column = 21 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 960691989
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 19, column = 13 }, end = { row = 19, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 13, column = 29 }, end = { row = 13, column = 34 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 15, column = 29 }, end = { row = 15, column = 36 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 7, column = 18 }, end = { row = 7, column = 24 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 11, column = 29 }, end = { row = 11, column = 35 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 17, column = 21 }, end = { row = 17, column = 37 } }
                                , category = "case-branch"
                                }
                              )
                            ]
                    , contentHash = 651500676
                    }
           }
         , { name = "caseInLet"
           , input = """
module NestedLetCaseIf exposing (caseInLet)

caseInLet : Maybe Int -> Int -> Int
caseInLet maybeX y =
    let
        x =
            case maybeX of
                Just val ->
                    val
                Nothing ->
                    0
    in
    x + y
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (caseInLet)

import Test.Coverage


caseInLet : Maybe Int -> Int -> Int
caseInLet maybeX y =
    let
        x =
            case
                let
                    _ =
                        Test.Coverage.track 357133973
                in
                maybeX
            of
                Just val ->
                    let
                        _ =
                            Test.Coverage.track 1615377089
                    in
                    val

                Nothing ->
                    let
                        _ =
                            Test.Coverage.track 353199476
                    in
                    0
    in
    let
        _ =
            Test.Coverage.track 2069063037
    in
    x + y
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 11, column = 21 }, end = { row = 11, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 7, column = 18 }, end = { row = 7, column = 24 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 9, column = 21 }, end = { row = 9, column = 24 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 13, column = 5 }, end = { row = 13, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 623895348
                    }
           }
         , { name = "ifInLet"
           , input = """
module NestedLetCaseIf exposing (ifInLet)

ifInLet : Bool -> Int -> Int
ifInLet flag value =
    let
        multiplier =
            if flag then
                2
            else
                1
    in
    value * multiplier
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (ifInLet)

import Test.Coverage


ifInLet : Bool -> Int -> Int
ifInLet flag value =
    let
        multiplier =
            if
                let
                    _ =
                        Test.Coverage.track 357133973
                in
                flag
            then
                let
                    _ =
                        Test.Coverage.track 1615377089
                in
                2

            else
                let
                    _ =
                        Test.Coverage.track 353199476
                in
                1
    in
    let
        _ =
            Test.Coverage.track 2069063037
    in
    value * multiplier
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 10, column = 17 }, end = { row = 10, column = 18 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 7, column = 16 }, end = { row = 7, column = 20 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 8, column = 17 }, end = { row = 8, column = 18 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 12, column = 5 }, end = { row = 12, column = 23 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 1167617865
                    }
           }
         , { name = "complexNested"
           , input = """
module NestedLetCaseIf exposing (complexNested)

complexNested : Maybe Int -> Bool -> String
complexNested maybeValue flag =
    let
        value =
            case maybeValue of
                Just x ->
                    x
                Nothing ->
                    0

        description =
            if flag then
                case value of
                    0 ->
                        "zero with flag"
                    1 ->
                        "one with flag"
                    _ ->
                        "other with flag"
            else
                case value of
                    0 ->
                        "zero without flag"
                    1 ->
                        "one without flag"
                    _ ->
                        "other without flag"
    in
    description
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (complexNested)

import Test.Coverage


complexNested : Maybe Int -> Bool -> String
complexNested maybeValue flag =
    let
        value =
            case
                let
                    _ =
                        Test.Coverage.track 357133973
                in
                maybeValue
            of
                Just x ->
                    let
                        _ =
                            Test.Coverage.track 1615377089
                    in
                    x

                Nothing ->
                    let
                        _ =
                            Test.Coverage.track 353199476
                    in
                    0

        description =
            if
                let
                    _ =
                        Test.Coverage.track 2069063037
                in
                flag
            then
                case
                    let
                        _ =
                            Test.Coverage.track 1161055252
                    in
                    value
                of
                    0 ->
                        let
                            _ =
                                Test.Coverage.track 1337164990
                        in
                        "zero with flag"

                    1 ->
                        let
                            _ =
                                Test.Coverage.track 2130358651
                        in
                        "one with flag"

                    _ ->
                        let
                            _ =
                                Test.Coverage.track 960691989
                        in
                        "other with flag"

            else
                case
                    let
                        _ =
                            Test.Coverage.track 1221367523
                    in
                    value
                of
                    0 ->
                        let
                            _ =
                                Test.Coverage.track 182652811
                        in
                        "zero without flag"

                    1 ->
                        let
                            _ =
                                Test.Coverage.track 431196966
                        in
                        "one without flag"

                    _ ->
                        let
                            _ =
                                Test.Coverage.track 798163806
                        in
                        "other without flag"
    in
    let
        _ =
            Test.Coverage.track 421798468
    in
    description
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 11, column = 21 }, end = { row = 11, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 7, column = 18 }, end = { row = 7, column = 28 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 431196966
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 27, column = 25 }, end = { row = 27, column = 43 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 798163806
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 29, column = 25 }, end = { row = 29, column = 45 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 421798468
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 31, column = 5 }, end = { row = 31, column = 16 } }
                                , category = "declaration"
                                }
                              )
                            , ( 960691989
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 21, column = 25 }, end = { row = 21, column = 42 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 15, column = 22 }, end = { row = 15, column = 27 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1221367523
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 23, column = 22 }, end = { row = 23, column = 27 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 17, column = 25 }, end = { row = 17, column = 41 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 9, column = 21 }, end = { row = 9, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 14, column = 16 }, end = { row = 14, column = 20 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 19, column = 25 }, end = { row = 19, column = 40 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 182652811
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 25, column = 25 }, end = { row = 25, column = 44 } }
                                , category = "case-branch"
                                }
                              )
                            ]
                    , contentHash = 316220396
                    }
           }
         , { name = "ifInIf"
           , input = """
module NestedLetCaseIf exposing (ifInIf)

ifInIf : Bool -> Bool -> String
ifInIf flag1 flag2 =
    if flag1 then
        if flag2 then
            "both true"
        else
            "first true"
    else
        if flag2 then
            "second true"
        else
            "both false"
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (ifInIf)

import Test.Coverage


ifInIf : Bool -> Bool -> String
ifInIf flag1 flag2 =
    if
        let
            _ =
                Test.Coverage.track 357133973
        in
        flag1
    then
        if
            let
                _ =
                    Test.Coverage.track 1615377089
            in
            flag2
        then
            let
                _ =
                    Test.Coverage.track 353199476
            in
            "both true"

        else
            let
                _ =
                    Test.Coverage.track 2069063037
            in
            "first true"

    else if
        let
            _ =
                Test.Coverage.track 1161055252
        in
        flag2
    then
        let
            _ =
                Test.Coverage.track 1337164990
        in
        "second true"

    else
        let
            _ =
                Test.Coverage.track 2130358651
        in
        "both false"
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInIf"
                                , range = { start = { row = 7, column = 13 }, end = { row = 7, column = 24 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInIf"
                                , range = { start = { row = 5, column = 8 }, end = { row = 5, column = 13 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInIf"
                                , range = { start = { row = 6, column = 12 }, end = { row = 6, column = 17 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInIf"
                                , range = { start = { row = 9, column = 13 }, end = { row = 9, column = 25 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInIf"
                                , range = { start = { row = 11, column = 12 }, end = { row = 11, column = 17 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInIf"
                                , range = { start = { row = 12, column = 13 }, end = { row = 12, column = 26 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInIf"
                                , range = { start = { row = 14, column = 13 }, end = { row = 14, column = 25 } }
                                , category = "if-branch"
                                }
                              )
                            ]
                    , contentHash = 2118387847
                    }
           }
         , { name = "caseInIf"
           , input = """
module NestedLetCaseIf exposing (caseInIf)

caseInIf : Bool -> Maybe Int -> String
caseInIf flag maybeValue =
    if flag then
        case maybeValue of
            Just x ->
                "flag true, value: " ++ String.fromInt x
            Nothing ->
                "flag true, no value"
    else
        case maybeValue of
            Just x ->
                "flag false, value: " ++ String.fromInt x
            Nothing ->
                "flag false, no value"
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (caseInIf)

import Test.Coverage


caseInIf : Bool -> Maybe Int -> String
caseInIf flag maybeValue =
    if
        let
            _ =
                Test.Coverage.track 357133973
        in
        flag
    then
        case
            let
                _ =
                    Test.Coverage.track 1615377089
            in
            maybeValue
        of
            Just x ->
                let
                    _ =
                        Test.Coverage.track 353199476
                in
                "flag true, value: " ++ String.fromInt x

            Nothing ->
                let
                    _ =
                        Test.Coverage.track 2069063037
                in
                "flag true, no value"

    else
        case
            let
                _ =
                    Test.Coverage.track 1161055252
            in
            maybeValue
        of
            Just x ->
                let
                    _ =
                        Test.Coverage.track 1337164990
                in
                "flag false, value: " ++ String.fromInt x

            Nothing ->
                let
                    _ =
                        Test.Coverage.track 2130358651
                in
                "flag false, no value"
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInIf"
                                , range = { start = { row = 8, column = 17 }, end = { row = 8, column = 57 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInIf"
                                , range = { start = { row = 5, column = 8 }, end = { row = 5, column = 12 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInIf"
                                , range = { start = { row = 12, column = 14 }, end = { row = 12, column = 24 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInIf"
                                , range = { start = { row = 14, column = 17 }, end = { row = 14, column = 58 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInIf"
                                , range = { start = { row = 6, column = 14 }, end = { row = 6, column = 24 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInIf"
                                , range = { start = { row = 10, column = 17 }, end = { row = 10, column = 38 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInIf"
                                , range = { start = { row = 16, column = 17 }, end = { row = 16, column = 39 } }
                                , category = "case-branch"
                                }
                              )
                            ]
                    , contentHash = 3889794027
                    }
           }
         , { name = "letInIf"
           , input = """
module NestedLetCaseIf exposing (letInIf)

letInIf : Bool -> Int -> Int
letInIf flag value =
    if flag then
        let
            multiplier = 2
            offset = 10
        in
        value * multiplier + offset
    else
        let
            multiplier = 1
            offset = 0
        in
        value * multiplier + offset
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (letInIf)

import Test.Coverage


letInIf : Bool -> Int -> Int
letInIf flag value =
    if
        let
            _ =
                Test.Coverage.track 357133973
        in
        flag
    then
        let
            multiplier =
                let
                    _ =
                        Test.Coverage.track 1615377089
                in
                2

            offset =
                let
                    _ =
                        Test.Coverage.track 353199476
                in
                10
        in
        let
            _ =
                Test.Coverage.track 2069063037
        in
        value * multiplier + offset

    else
        let
            multiplier =
                let
                    _ =
                        Test.Coverage.track 1161055252
                in
                1

            offset =
                let
                    _ =
                        Test.Coverage.track 1337164990
                in
                0
        in
        let
            _ =
                Test.Coverage.track 2130358651
        in
        value * multiplier + offset
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInIf"
                                , range = { start = { row = 8, column = 22 }, end = { row = 8, column = 24 } }
                                , category = "declaration"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInIf"
                                , range = { start = { row = 5, column = 8 }, end = { row = 5, column = 12 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInIf"
                                , range = { start = { row = 13, column = 26 }, end = { row = 13, column = 27 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInIf"
                                , range = { start = { row = 14, column = 22 }, end = { row = 14, column = 23 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInIf"
                                , range = { start = { row = 7, column = 26 }, end = { row = 7, column = 27 } }
                                , category = "declaration"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInIf"
                                , range = { start = { row = 10, column = 9 }, end = { row = 10, column = 36 } }
                                , category = "declaration"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInIf"
                                , range = { start = { row = 16, column = 9 }, end = { row = 16, column = 36 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 2584561090
                    }
           }
         , { name = "ifInCase"
           , input = """
module NestedLetCaseIf exposing (ifInCase)

ifInCase : Maybe Bool -> Int -> String
ifInCase maybeFlag value =
    case maybeFlag of
        Just flag ->
            if flag then
                "flag is true, value: " ++ String.fromInt value
            else
                "flag is false, value: " ++ String.fromInt value
        Nothing ->
            "no flag, value: " ++ String.fromInt value
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (ifInCase)

import Test.Coverage


ifInCase : Maybe Bool -> Int -> String
ifInCase maybeFlag value =
    case
        let
            _ =
                Test.Coverage.track 357133973
        in
        maybeFlag
    of
        Just flag ->
            if
                let
                    _ =
                        Test.Coverage.track 1615377089
                in
                flag
            then
                let
                    _ =
                        Test.Coverage.track 353199476
                in
                "flag is true, value: " ++ String.fromInt value

            else
                let
                    _ =
                        Test.Coverage.track 2069063037
                in
                "flag is false, value: " ++ String.fromInt value

        Nothing ->
            let
                _ =
                    Test.Coverage.track 1161055252
            in
            "no flag, value: " ++ String.fromInt value
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInCase"
                                , range = { start = { row = 8, column = 17 }, end = { row = 8, column = 64 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInCase"
                                , range = { start = { row = 5, column = 10 }, end = { row = 5, column = 19 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInCase"
                                , range = { start = { row = 7, column = 16 }, end = { row = 7, column = 20 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInCase"
                                , range = { start = { row = 10, column = 17 }, end = { row = 10, column = 65 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInCase"
                                , range = { start = { row = 12, column = 13 }, end = { row = 12, column = 55 } }
                                , category = "case-branch"
                                }
                              )
                            ]
                    , contentHash = 3613902745
                    }
           }
         , { name = "letInCase"
           , input = """
module NestedLetCaseIf exposing (letInCase)

letInCase : Maybe Int -> Int -> Int
letInCase maybeX y =
    case maybeX of
        Just x ->
            let
                doubled = x * 2
                tripled = doubled + x
            in
            tripled + y
        Nothing ->
            let
                default = 0
                adjusted = default + 5
            in
            adjusted + y
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (letInCase)

import Test.Coverage


letInCase : Maybe Int -> Int -> Int
letInCase maybeX y =
    case
        let
            _ =
                Test.Coverage.track 357133973
        in
        maybeX
    of
        Just x ->
            let
                doubled =
                    let
                        _ =
                            Test.Coverage.track 1615377089
                    in
                    x * 2

                tripled =
                    let
                        _ =
                            Test.Coverage.track 353199476
                    in
                    doubled + x
            in
            let
                _ =
                    Test.Coverage.track 2069063037
            in
            tripled + y

        Nothing ->
            let
                default =
                    let
                        _ =
                            Test.Coverage.track 1161055252
                    in
                    0

                adjusted =
                    let
                        _ =
                            Test.Coverage.track 1337164990
                    in
                    default + 5
            in
            let
                _ =
                    Test.Coverage.track 2130358651
            in
            adjusted + y
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInCase"
                                , range = { start = { row = 9, column = 27 }, end = { row = 9, column = 38 } }
                                , category = "declaration"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInCase"
                                , range = { start = { row = 5, column = 10 }, end = { row = 5, column = 16 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInCase"
                                , range = { start = { row = 14, column = 27 }, end = { row = 14, column = 28 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInCase"
                                , range = { start = { row = 15, column = 28 }, end = { row = 15, column = 39 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInCase"
                                , range = { start = { row = 8, column = 27 }, end = { row = 8, column = 32 } }
                                , category = "declaration"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInCase"
                                , range = { start = { row = 11, column = 13 }, end = { row = 11, column = 24 } }
                                , category = "declaration"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInCase"
                                , range = { start = { row = 17, column = 13 }, end = { row = 17, column = 25 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 2350833290
                    }
           }
         , { name = "letInLet"
           , input = """
module NestedLetCaseIf exposing (letInLet)

letInLet : Int -> Int -> Int
letInLet x y =
    let
        a =
            let
                doubled = x * 2
            in
            doubled
        b =
            let
                tripled = y * 3
            in
            tripled
    in
    a + b
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (letInLet)

import Test.Coverage


letInLet : Int -> Int -> Int
letInLet x y =
    let
        a =
            let
                doubled =
                    let
                        _ =
                            Test.Coverage.track 357133973
                    in
                    x * 2
            in
            let
                _ =
                    Test.Coverage.track 1615377089
            in
            doubled

        b =
            let
                tripled =
                    let
                        _ =
                            Test.Coverage.track 353199476
                    in
                    y * 3
            in
            let
                _ =
                    Test.Coverage.track 2069063037
            in
            tripled
    in
    let
        _ =
            Test.Coverage.track 1161055252
    in
    a + b
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInLet"
                                , range = { start = { row = 13, column = 27 }, end = { row = 13, column = 32 } }
                                , category = "declaration"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInLet"
                                , range = { start = { row = 8, column = 27 }, end = { row = 8, column = 32 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInLet"
                                , range = { start = { row = 17, column = 5 }, end = { row = 17, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInLet"
                                , range = { start = { row = 10, column = 13 }, end = { row = 10, column = 20 } }
                                , category = "declaration"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "letInLet"
                                , range = { start = { row = 15, column = 13 }, end = { row = 15, column = 20 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 1293654449
                    }
           }
         ]
            |> List.map testCase
        )


trimSuccess : Main.Output -> Main.Output
trimSuccess output =
    output
        |> Result.map
            (\success ->
                { success | instrumentedElmSourceCode = String.trim success.instrumentedElmSourceCode }
            )


testCase : TestCase -> Test
testCase tc =
    Test.test tc.name <|
        \() ->
            { elmSourceCode = String.trim tc.input }
                |> Main.work
                |> trimSuccess
                |> Expect.equal (trimSuccess tc.output)
