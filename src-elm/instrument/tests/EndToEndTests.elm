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
         , { name = "listWithCaseIfLet"
           , input = """
module NestedLetCaseIf exposing (listWithCaseIfLet)

listWithCaseIfLet : Maybe Int -> Bool -> List Int
listWithCaseIfLet maybe b =
    [ case maybe of
        Just v ->
            v
        Nothing ->
            0
    , if b then
        1
      else
        2
    , let
        z = 1
      in
        z
    ]
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (listWithCaseIfLet)

import Test.Coverage


listWithCaseIfLet : Maybe Int -> Bool -> List Int
listWithCaseIfLet maybe b =
    [ case
        let
            _ =
                Test.Coverage.track 357133973
        in
        maybe
      of
        Just v ->
            let
                _ =
                    Test.Coverage.track 1615377089
            in
            v

        Nothing ->
            let
                _ =
                    Test.Coverage.track 353199476
            in
            0
    , if
        let
            _ =
                Test.Coverage.track 2069063037
        in
        b
      then
        let
            _ =
                Test.Coverage.track 1161055252
        in
        1

      else
        let
            _ =
                Test.Coverage.track 1337164990
        in
        2
    , let
        z =
            let
                _ =
                    Test.Coverage.track 2130358651
            in
            1
      in
      let
        _ =
            Test.Coverage.track 960691989
      in
      z
    ]
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "listWithCaseIfLet"
                                , range = { start = { row = 9, column = 13 }, end = { row = 9, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "listWithCaseIfLet"
                                , range = { start = { row = 5, column = 12 }, end = { row = 5, column = 17 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 960691989
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "listWithCaseIfLet"
                                , range = { start = { row = 17, column = 9 }, end = { row = 17, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "listWithCaseIfLet"
                                , range = { start = { row = 11, column = 9 }, end = { row = 11, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "listWithCaseIfLet"
                                , range = { start = { row = 13, column = 9 }, end = { row = 13, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "listWithCaseIfLet"
                                , range = { start = { row = 7, column = 13 }, end = { row = 7, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "listWithCaseIfLet"
                                , range = { start = { row = 10, column = 10 }, end = { row = 10, column = 11 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "listWithCaseIfLet"
                                , range = { start = { row = 15, column = 13 }, end = { row = 15, column = 14 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 18538211
                    }
           }
         , { name = "tuple3WithCaseIfLet"
           , input = """
module NestedLetCaseIf exposing (tuple3WithCaseIfLet)

tuple3WithCaseIfLet : Maybe Int -> Bool -> ( Int, Int, Int )
tuple3WithCaseIfLet maybe b =
    ( case maybe of
        Just v ->
            v
        Nothing ->
            0
    , if b then
        1
      else
        2
    , let
        z = 1
      in
        z
    )
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (tuple3WithCaseIfLet)

import Test.Coverage


tuple3WithCaseIfLet : Maybe Int -> Bool -> ( Int, Int, Int )
tuple3WithCaseIfLet maybe b =
    ( case
        let
            _ =
                Test.Coverage.track 357133973
        in
        maybe
      of
        Just v ->
            let
                _ =
                    Test.Coverage.track 1615377089
            in
            v

        Nothing ->
            let
                _ =
                    Test.Coverage.track 353199476
            in
            0
    , if
        let
            _ =
                Test.Coverage.track 2069063037
        in
        b
      then
        let
            _ =
                Test.Coverage.track 1161055252
        in
        1

      else
        let
            _ =
                Test.Coverage.track 1337164990
        in
        2
    , let
        z =
            let
                _ =
                    Test.Coverage.track 2130358651
            in
            1
      in
      let
        _ =
            Test.Coverage.track 960691989
      in
      z
    )
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "tuple3WithCaseIfLet"
                                , range = { start = { row = 9, column = 13 }, end = { row = 9, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "tuple3WithCaseIfLet"
                                , range = { start = { row = 5, column = 12 }, end = { row = 5, column = 17 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 960691989
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "tuple3WithCaseIfLet"
                                , range = { start = { row = 17, column = 9 }, end = { row = 17, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "tuple3WithCaseIfLet"
                                , range = { start = { row = 11, column = 9 }, end = { row = 11, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "tuple3WithCaseIfLet"
                                , range = { start = { row = 13, column = 9 }, end = { row = 13, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "tuple3WithCaseIfLet"
                                , range = { start = { row = 7, column = 13 }, end = { row = 7, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "tuple3WithCaseIfLet"
                                , range = { start = { row = 10, column = 10 }, end = { row = 10, column = 11 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "tuple3WithCaseIfLet"
                                , range = { start = { row = 15, column = 13 }, end = { row = 15, column = 14 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 1238790634
                    }
           }
         , { name = "recordWithCaseIfLet"
           , input = """
module NestedLetCaseIf exposing (recordWithCaseIfLet)

recordWithCaseIfLet : Maybe Int -> Bool -> { a : Int, b : Int, c : Int }
recordWithCaseIfLet maybe b =
    { a =
        case maybe of
            Just v ->
                v
            Nothing ->
                0
    , b =
        if b then
            1
        else
            2
    , c =
        let
            z = 1
        in
            z
    }
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (recordWithCaseIfLet)

import Test.Coverage


recordWithCaseIfLet : Maybe Int -> Bool -> { a : Int, b : Int, c : Int }
recordWithCaseIfLet maybe b =
    { a =
        case
            let
                _ =
                    Test.Coverage.track 357133973
            in
            maybe
        of
            Just v ->
                let
                    _ =
                        Test.Coverage.track 1615377089
                in
                v

            Nothing ->
                let
                    _ =
                        Test.Coverage.track 353199476
                in
                0
    , b =
        if
            let
                _ =
                    Test.Coverage.track 2069063037
            in
            b
        then
            let
                _ =
                    Test.Coverage.track 1161055252
            in
            1

        else
            let
                _ =
                    Test.Coverage.track 1337164990
            in
            2
    , c =
        let
            z =
                let
                    _ =
                        Test.Coverage.track 2130358651
                in
                1
        in
        let
            _ =
                Test.Coverage.track 960691989
        in
        z
    }
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordWithCaseIfLet"
                                , range = { start = { row = 10, column = 17 }, end = { row = 10, column = 18 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordWithCaseIfLet"
                                , range = { start = { row = 6, column = 14 }, end = { row = 6, column = 19 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 960691989
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordWithCaseIfLet"
                                , range = { start = { row = 20, column = 13 }, end = { row = 20, column = 14 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordWithCaseIfLet"
                                , range = { start = { row = 13, column = 13 }, end = { row = 13, column = 14 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordWithCaseIfLet"
                                , range = { start = { row = 15, column = 13 }, end = { row = 15, column = 14 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordWithCaseIfLet"
                                , range = { start = { row = 8, column = 17 }, end = { row = 8, column = 18 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordWithCaseIfLet"
                                , range = { start = { row = 12, column = 12 }, end = { row = 12, column = 13 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordWithCaseIfLet"
                                , range = { start = { row = 18, column = 17 }, end = { row = 18, column = 18 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 1663106059
                    }
           }
         , { name = "recordWithPlainFields"
           , input = """
module RecordPlain exposing (f)

f : Int -> { a : Int, b : Int }
f x =
    { a = identity x
    , b = x + 1
    }
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module RecordPlain exposing (f)

import Test.Coverage


f : Int -> { a : Int, b : Int }
f x =
    { a =
        let
            _ =
                Test.Coverage.track 518031371
        in
        identity x
    , b =
        let
            _ =
                Test.Coverage.track 121624604
        in
        x + 1
    }
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 121624604
                              , { moduleName = "RecordPlain"
                                , moduleFilePath = "RecordPlain.elm"
                                , declarationName = "f"
                                , range = { start = { row = 6, column = 11 }, end = { row = 6, column = 16 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 518031371
                              , { moduleName = "RecordPlain"
                                , moduleFilePath = "RecordPlain.elm"
                                , declarationName = "f"
                                , range = { start = { row = 5, column = 11 }, end = { row = 5, column = 21 } }
                                , category = "subexpression"
                                }
                              )
                            ]
                    , contentHash = 1220215621
                    }
           }
         , { name = "recordUpdateWithCaseIfLet"
           , input = """
module NestedLetCaseIf exposing (recordUpdateWithCaseIfLet)

recordUpdateWithCaseIfLet : { r | a : Int, b : Int, c : Int } -> Maybe Int -> Bool -> { a : Int, b : Int, c : Int }
recordUpdateWithCaseIfLet r maybe b =
    { r
        | a =
            case maybe of
                Just v ->
                    v
                Nothing ->
                    0
        , b =
            if b then
                1
            else
                2
        , c =
            let
                z = 1
            in
                z
    }
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (recordUpdateWithCaseIfLet)

import Test.Coverage


recordUpdateWithCaseIfLet : { r | a : Int, b : Int, c : Int } -> Maybe Int -> Bool -> { a : Int, b : Int, c : Int }
recordUpdateWithCaseIfLet r maybe b =
    { r
        | a =
            case
                let
                    _ =
                        Test.Coverage.track 357133973
                in
                maybe
            of
                Just v ->
                    let
                        _ =
                            Test.Coverage.track 1615377089
                    in
                    v

                Nothing ->
                    let
                        _ =
                            Test.Coverage.track 353199476
                    in
                    0
        , b =
            if
                let
                    _ =
                        Test.Coverage.track 2069063037
                in
                b
            then
                let
                    _ =
                        Test.Coverage.track 1161055252
                in
                1

            else
                let
                    _ =
                        Test.Coverage.track 1337164990
                in
                2
        , c =
            let
                z =
                    let
                        _ =
                            Test.Coverage.track 2130358651
                    in
                    1
            in
            let
                _ =
                    Test.Coverage.track 960691989
            in
            z
    }
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordUpdateWithCaseIfLet"
                                , range = { start = { row = 11, column = 21 }, end = { row = 11, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordUpdateWithCaseIfLet"
                                , range = { start = { row = 7, column = 18 }, end = { row = 7, column = 23 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 960691989
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordUpdateWithCaseIfLet"
                                , range = { start = { row = 21, column = 17 }, end = { row = 21, column = 18 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordUpdateWithCaseIfLet"
                                , range = { start = { row = 14, column = 17 }, end = { row = 14, column = 18 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordUpdateWithCaseIfLet"
                                , range = { start = { row = 16, column = 17 }, end = { row = 16, column = 18 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordUpdateWithCaseIfLet"
                                , range = { start = { row = 9, column = 21 }, end = { row = 9, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordUpdateWithCaseIfLet"
                                , range = { start = { row = 13, column = 16 }, end = { row = 13, column = 17 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "recordUpdateWithCaseIfLet"
                                , range = { start = { row = 19, column = 21 }, end = { row = 19, column = 22 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 2442142228
                    }
           }
         , { name = "parenthesizedCase"
           , input = """
module NestedLetCaseIf exposing (parenthesizedCase)

parenthesizedCase : Maybe Int -> Int
parenthesizedCase maybe =
    ( case maybe of
        Just v ->
            v
        Nothing ->
            0
    )
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module NestedLetCaseIf exposing (parenthesizedCase)

import Test.Coverage


parenthesizedCase : Maybe Int -> Int
parenthesizedCase maybe =
    case
        let
            _ =
                Test.Coverage.track 357133973
        in
        maybe
    of
        Just v ->
            let
                _ =
                    Test.Coverage.track 1615377089
            in
            v

        Nothing ->
            let
                _ =
                    Test.Coverage.track 353199476
            in
            0
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "parenthesizedCase"
                                , range = { start = { row = 9, column = 13 }, end = { row = 9, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "parenthesizedCase"
                                , range = { start = { row = 5, column = 12 }, end = { row = 5, column = 17 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "parenthesizedCase"
                                , range = { start = { row = 7, column = 13 }, end = { row = 7, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            ]
                    , contentHash = 3396872701
                    }
           }
         , { name = "pipeCaseBack"
           , input = """
module PipeCaseBack exposing (caseBack)

caseBack : Bool -> Maybe Int -> Int
caseBack b maybe =
    (case b of
        True ->
            identity
        False ->
            identity
    )
        <|
    (case maybe of
        Just v ->
            v
        Nothing ->
            0
    )
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module PipeCaseBack exposing (caseBack)

import Test.Coverage


caseBack : Bool -> Maybe Int -> Int
caseBack b maybe =
    (case
        let
            _ =
                Test.Coverage.track 2045197287
        in
        b
     of
        True ->
            let
                _ =
                    Test.Coverage.track 739936688
            in
            identity

        False ->
            let
                _ =
                    Test.Coverage.track 1276886640
            in
            identity
    )
    <|
        case
            let
                _ =
                    Test.Coverage.track 922233771
            in
            maybe
        of
            Just v ->
                let
                    _ =
                        Test.Coverage.track 1241319463
                in
                v

            Nothing ->
                let
                    _ =
                        Test.Coverage.track 551250307
                in
                0

"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 551250307
                              , { moduleName = "PipeCaseBack"
                                , moduleFilePath = "PipeCaseBack.elm"
                                , declarationName = "caseBack"
                                , range = { start = { row = 16, column = 13 }, end = { row = 16, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 739936688
                              , { moduleName = "PipeCaseBack"
                                , moduleFilePath = "PipeCaseBack.elm"
                                , declarationName = "caseBack"
                                , range = { start = { row = 7, column = 13 }, end = { row = 7, column = 21 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 922233771
                              , { moduleName = "PipeCaseBack"
                                , moduleFilePath = "PipeCaseBack.elm"
                                , declarationName = "caseBack"
                                , range = { start = { row = 12, column = 11 }, end = { row = 12, column = 16 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1241319463
                              , { moduleName = "PipeCaseBack"
                                , moduleFilePath = "PipeCaseBack.elm"
                                , declarationName = "caseBack"
                                , range = { start = { row = 14, column = 13 }, end = { row = 14, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1276886640
                              , { moduleName = "PipeCaseBack"
                                , moduleFilePath = "PipeCaseBack.elm"
                                , declarationName = "caseBack"
                                , range = { start = { row = 9, column = 13 }, end = { row = 9, column = 21 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2045197287
                              , { moduleName = "PipeCaseBack"
                                , moduleFilePath = "PipeCaseBack.elm"
                                , declarationName = "caseBack"
                                , range = { start = { row = 5, column = 11 }, end = { row = 5, column = 12 } }
                                , category = "subexpression"
                                }
                              )
                            ]
                    , contentHash = 1874857240
                    }
           }

         , { name = "pipeCaseForward"
           , input = """
module PipeCaseForward exposing (caseForward)

caseForward : Maybe Int -> Bool -> Int
caseForward maybe b =
    (case maybe of
        Just v ->
            v
        Nothing ->
            0
    )
        |>
    (case b of
        True ->
            identity
        False ->
            identity
    )
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module PipeCaseForward exposing (caseForward)

import Test.Coverage


caseForward : Maybe Int -> Bool -> Int
caseForward maybe b =
    (case
        let
            _ =
                Test.Coverage.track 245550410
        in
        maybe
     of
        Just v ->
            let
                _ =
                    Test.Coverage.track 1699498773
            in
            v

        Nothing ->
            let
                _ =
                    Test.Coverage.track 475321681
            in
            0
    )
        |> (case
                let
                    _ =
                        Test.Coverage.track 1162223125
                in
                b
            of
                True ->
                    let
                        _ =
                            Test.Coverage.track 137389808
                    in
                    identity

                False ->
                    let
                        _ =
                            Test.Coverage.track 802548351
                    in
                    identity
           )

"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 137389808
                              , { moduleName = "PipeCaseForward"
                                , moduleFilePath = "PipeCaseForward.elm"
                                , declarationName = "caseForward"
                                , range = { start = { row = 14, column = 13 }, end = { row = 14, column = 21 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 245550410
                              , { moduleName = "PipeCaseForward"
                                , moduleFilePath = "PipeCaseForward.elm"
                                , declarationName = "caseForward"
                                , range = { start = { row = 5, column = 11 }, end = { row = 5, column = 16 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 475321681
                              , { moduleName = "PipeCaseForward"
                                , moduleFilePath = "PipeCaseForward.elm"
                                , declarationName = "caseForward"
                                , range = { start = { row = 9, column = 13 }, end = { row = 9, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 802548351
                              , { moduleName = "PipeCaseForward"
                                , moduleFilePath = "PipeCaseForward.elm"
                                , declarationName = "caseForward"
                                , range = { start = { row = 16, column = 13 }, end = { row = 16, column = 21 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1162223125
                              , { moduleName = "PipeCaseForward"
                                , moduleFilePath = "PipeCaseForward.elm"
                                , declarationName = "caseForward"
                                , range = { start = { row = 12, column = 11 }, end = { row = 12, column = 12 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1699498773
                              , { moduleName = "PipeCaseForward"
                                , moduleFilePath = "PipeCaseForward.elm"
                                , declarationName = "caseForward"
                                , range = { start = { row = 7, column = 13 }, end = { row = 7, column = 14 } }
                                , category = "case-branch"
                                }
                              )
                            ]
                    , contentHash = 2575270262
                    }
           }

         , { name = "pipeIfBack"
           , input = """
module PipeIfBack exposing (ifBack)

ifBack : Bool -> Bool -> Int
ifBack b1 b2 =
    (if b1 then
        identity
     else
        identity
    )
        <|
    (if b2 then
        1
     else
        2
    )
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module PipeIfBack exposing (ifBack)

import Test.Coverage


ifBack : Bool -> Bool -> Int
ifBack b1 b2 =
    (if
        let
            _ =
                Test.Coverage.track 262901614
        in
        b1
     then
        let
            _ =
                Test.Coverage.track 1854181018
        in
        identity

     else
        let
            _ =
                Test.Coverage.track 982570730
        in
        identity
    )
    <|
        if
            let
                _ =
                    Test.Coverage.track 394066845
            in
            b2
        then
            let
                _ =
                    Test.Coverage.track 667013035
            in
            1

        else
            let
                _ =
                    Test.Coverage.track 1036825911
            in
            2

"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 262901614
                              , { moduleName = "PipeIfBack"
                                , moduleFilePath = "PipeIfBack.elm"
                                , declarationName = "ifBack"
                                , range = { start = { row = 5, column = 9 }, end = { row = 5, column = 11 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 394066845
                              , { moduleName = "PipeIfBack"
                                , moduleFilePath = "PipeIfBack.elm"
                                , declarationName = "ifBack"
                                , range = { start = { row = 11, column = 9 }, end = { row = 11, column = 11 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 667013035
                              , { moduleName = "PipeIfBack"
                                , moduleFilePath = "PipeIfBack.elm"
                                , declarationName = "ifBack"
                                , range = { start = { row = 12, column = 9 }, end = { row = 12, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 982570730
                              , { moduleName = "PipeIfBack"
                                , moduleFilePath = "PipeIfBack.elm"
                                , declarationName = "ifBack"
                                , range = { start = { row = 8, column = 9 }, end = { row = 8, column = 17 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1036825911
                              , { moduleName = "PipeIfBack"
                                , moduleFilePath = "PipeIfBack.elm"
                                , declarationName = "ifBack"
                                , range = { start = { row = 14, column = 9 }, end = { row = 14, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1854181018
                              , { moduleName = "PipeIfBack"
                                , moduleFilePath = "PipeIfBack.elm"
                                , declarationName = "ifBack"
                                , range = { start = { row = 6, column = 9 }, end = { row = 6, column = 17 } }
                                , category = "if-branch"
                                }
                              )
                            ]
                    , contentHash = 282854936
                    }
           }

         , { name = "pipeIfForward"
           , input = """
module PipeIfForward exposing (ifForward)

ifForward : Bool -> Bool -> Int
ifForward b1 b2 =
    (if b1 then
        1
     else
        2
    )
        |>
    (if b2 then
        identity
     else
        identity
    )
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module PipeIfForward exposing (ifForward)

import Test.Coverage


ifForward : Bool -> Bool -> Int
ifForward b1 b2 =
    (if
        let
            _ =
                Test.Coverage.track 938233759
        in
        b1
     then
        let
            _ =
                Test.Coverage.track 129963358
        in
        1

     else
        let
            _ =
                Test.Coverage.track 132570911
        in
        2
    )
        |> (if
                let
                    _ =
                        Test.Coverage.track 1479741856
                in
                b2
            then
                let
                    _ =
                        Test.Coverage.track 706474280
                in
                identity

            else
                let
                    _ =
                        Test.Coverage.track 1906405830
                in
                identity
           )

"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 129963358
                              , { moduleName = "PipeIfForward"
                                , moduleFilePath = "PipeIfForward.elm"
                                , declarationName = "ifForward"
                                , range = { start = { row = 6, column = 9 }, end = { row = 6, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 132570911
                              , { moduleName = "PipeIfForward"
                                , moduleFilePath = "PipeIfForward.elm"
                                , declarationName = "ifForward"
                                , range = { start = { row = 8, column = 9 }, end = { row = 8, column = 10 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 706474280
                              , { moduleName = "PipeIfForward"
                                , moduleFilePath = "PipeIfForward.elm"
                                , declarationName = "ifForward"
                                , range = { start = { row = 12, column = 9 }, end = { row = 12, column = 17 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 938233759
                              , { moduleName = "PipeIfForward"
                                , moduleFilePath = "PipeIfForward.elm"
                                , declarationName = "ifForward"
                                , range = { start = { row = 5, column = 9 }, end = { row = 5, column = 11 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1479741856
                              , { moduleName = "PipeIfForward"
                                , moduleFilePath = "PipeIfForward.elm"
                                , declarationName = "ifForward"
                                , range = { start = { row = 11, column = 9 }, end = { row = 11, column = 11 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1906405830
                              , { moduleName = "PipeIfForward"
                                , moduleFilePath = "PipeIfForward.elm"
                                , declarationName = "ifForward"
                                , range = { start = { row = 14, column = 9 }, end = { row = 14, column = 17 } }
                                , category = "if-branch"
                                }
                              )
                            ]
                    , contentHash = 699154076
                    }
           }

         , { name = "pipeLetBack"
           , input = """
module PipeLetBack exposing (letBack)

letBack : Int
letBack =
    (let
        f = identity
     in
        f
    )
        <|
    (let
        x = 0
     in
        x
    )
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module PipeLetBack exposing (letBack)

import Test.Coverage


letBack : Int
letBack =
    (let
        f =
            let
                _ =
                    Test.Coverage.track 1428706580
            in
            identity
     in
     let
        _ =
            Test.Coverage.track 75018641
     in
     f
    )
    <|
        let
            x =
                let
                    _ =
                        Test.Coverage.track 628164565
                in
                0
        in
        let
            _ =
                Test.Coverage.track 1563554100
        in
        x

"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 75018641
                              , { moduleName = "PipeLetBack"
                                , moduleFilePath = "PipeLetBack.elm"
                                , declarationName = "letBack"
                                , range = { start = { row = 8, column = 9 }, end = { row = 8, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            , ( 628164565
                              , { moduleName = "PipeLetBack"
                                , moduleFilePath = "PipeLetBack.elm"
                                , declarationName = "letBack"
                                , range = { start = { row = 12, column = 13 }, end = { row = 12, column = 14 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1428706580
                              , { moduleName = "PipeLetBack"
                                , moduleFilePath = "PipeLetBack.elm"
                                , declarationName = "letBack"
                                , range = { start = { row = 6, column = 13 }, end = { row = 6, column = 21 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1563554100
                              , { moduleName = "PipeLetBack"
                                , moduleFilePath = "PipeLetBack.elm"
                                , declarationName = "letBack"
                                , range = { start = { row = 14, column = 9 }, end = { row = 14, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 3319814615
                    }
           }

         , { name = "pipeLetForward"
           , input = """
module PipeLetForward exposing (letForward)

letForward : Int
letForward =
    (let
        x = 0
     in
        x
    )
        |>
    (let
        f = identity
     in
        f
    )
"""
           , output =
                Ok
                    { instrumentedElmSourceCode = """
module PipeLetForward exposing (letForward)

import Test.Coverage


letForward : Int
letForward =
    (let
        x =
            let
                _ =
                    Test.Coverage.track 1890667586
            in
            0
     in
     let
        _ =
            Test.Coverage.track 1647562504
     in
     x
    )
        |> (let
                f =
                    let
                        _ =
                            Test.Coverage.track 1396064972
                    in
                    identity
            in
            let
                _ =
                    Test.Coverage.track 708398536
            in
            f
           )

"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 708398536
                              , { moduleName = "PipeLetForward"
                                , moduleFilePath = "PipeLetForward.elm"
                                , declarationName = "letForward"
                                , range = { start = { row = 14, column = 9 }, end = { row = 14, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1396064972
                              , { moduleName = "PipeLetForward"
                                , moduleFilePath = "PipeLetForward.elm"
                                , declarationName = "letForward"
                                , range = { start = { row = 12, column = 13 }, end = { row = 12, column = 21 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1647562504
                              , { moduleName = "PipeLetForward"
                                , moduleFilePath = "PipeLetForward.elm"
                                , declarationName = "letForward"
                                , range = { start = { row = 8, column = 9 }, end = { row = 8, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1890667586
                              , { moduleName = "PipeLetForward"
                                , moduleFilePath = "PipeLetForward.elm"
                                , declarationName = "letForward"
                                , range = { start = { row = 6, column = 13 }, end = { row = 6, column = 14 } }
                                , category = "declaration"
                                }
                              )
                            ]
                    , contentHash = 561091049
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
