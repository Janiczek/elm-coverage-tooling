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
                Test.Coverage.track 107558697
        in
        5

    else
        let
            _ =
                Test.Coverage.track 1885435985
        in
        6
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 107558697
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 6, column = 9 }, end = { row = 6, column = 10 } }
                                , category = "if-branch"
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
                Test.Coverage.track 107558697
        in
        ()

    else if
        (let
            _ =
                Test.Coverage.track 1885435985
         in
         b == 2
        )
            || (let
                    _ =
                        Test.Coverage.track 434548591
                in
                c == 2
               )
    then
        let
            _ =
                Test.Coverage.track 1004572879
        in
        ()

    else
        let
            _ =
                Test.Coverage.track 1045688889
        in
        ()

"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 107558697
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 9 }, end = { row = 5, column = 11 } }
                                , category = "if-branch"
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
                                , range = { start = { row = 6, column = 23 }, end = { row = 6, column = 29 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1004572879
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 7, column = 9 }, end = { row = 7, column = 11 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1045688889
                              , { moduleName = "A"
                                , moduleFilePath = "A.elm"
                                , declarationName = "a"
                                , range = { start = { row = 9, column = 9 }, end = { row = 9, column = 11 } }
                                , category = "if-branch"
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
                                , range = { start = { row = 6, column = 13 }, end = { row = 6, column = 19 } }
                                , category = "subexpression"
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
         , { name = "nested let-case-if"
           , input = """
module NestedLetCaseIf exposing (nestedCaseOf, caseInLet, ifInLet, complexNested)

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
module NestedLetCaseIf exposing (caseInLet, complexNested, ifInLet, nestedCaseOf)

import Test.Coverage


complexNested : Maybe Int -> Bool -> String
complexNested maybeValue flag =
    let
        value =
            let
                _ =
                    Test.Coverage.track
                        954960163
            in
            case
                let
                    _ =
                        Test.Coverage.track 65480399
                in
                maybeValue
            of
                Just x ->
                    let
                        _ =
                            Test.Coverage.track 159104197
                    in
                    x

                Nothing ->
                    let
                        _ =
                            Test.Coverage.track 1479773536
                    in
                    0

        description =
            let
                _ =
                    Test.Coverage.track
                        1469809502
            in
            if flag then
                case
                    let
                        _ =
                            Test.Coverage.track 1210665696
                    in
                    value
                of
                    0 ->
                        let
                            _ =
                                Test.Coverage.track 1146639121
                        in
                        "zero with flag"

                    1 ->
                        let
                            _ =
                                Test.Coverage.track 1386782202
                        in
                        "one with flag"

                    _ ->
                        let
                            _ =
                                Test.Coverage.track 662760606
                        in
                        "other with flag"

            else
                case
                    let
                        _ =
                            Test.Coverage.track 329579790
                    in
                    value
                of
                    0 ->
                        let
                            _ =
                                Test.Coverage.track 1111335368
                        in
                        "zero without flag"

                    1 ->
                        let
                            _ =
                                Test.Coverage.track 2001614685
                        in
                        "one without flag"

                    _ ->
                        let
                            _ =
                                Test.Coverage.track 1724073323
                        in
                        "other without flag"
    in
    let
        _ =
            Test.Coverage.track 23467525
    in
    description


ifInLet : Bool -> Int -> Int
ifInLet flag value =
    let
        multiplier =
            let
                _ =
                    Test.Coverage.track
                        1503310822
            in
            if flag then
                let
                    _ =
                        Test.Coverage.track 9892290
                in
                2

            else
                let
                    _ =
                        Test.Coverage.track 984664282
                in
                1
    in
    let
        _ =
            Test.Coverage.track 169508008
    in
    value * multiplier


caseInLet : Maybe Int -> Int -> Int
caseInLet maybeX y =
    let
        x =
            let
                _ =
                    Test.Coverage.track
                        421798468
            in
            case
                let
                    _ =
                        Test.Coverage.track 182652811
                in
                maybeX
            of
                Just val ->
                    let
                        _ =
                            Test.Coverage.track 431196966
                    in
                    val

                Nothing ->
                    let
                        _ =
                            Test.Coverage.track 798163806
                    in
                    0
    in
    let
        _ =
            Test.Coverage.track 1698499172
    in
    x + y


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
                            [ ( 9892290
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 41, column = 17 }, end = { row = 41, column = 18 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 65480399
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 52, column = 18 }, end = { row = 52, column = 28 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 159104197
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 54, column = 21 }, end = { row = 54, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1469809502
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 59, column = 13 }, end = { row = 74, column = 45 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1724073323
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 74, column = 25 }, end = { row = 74, column = 45 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1503310822
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 40, column = 13 }, end = { row = 43, column = 18 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1479773536
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 56, column = 21 }, end = { row = 56, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1503310822
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 40, column = 13 }, end = { row = 43, column = 18 } }
                                , category = "declaration"
                                }
                              )
                            , ( 169508008
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 45, column = 5 }, end = { row = 45, column = 23 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1698499172
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 33, column = 5 }, end = { row = 33, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1724073323
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 74, column = 25 }, end = { row = 74, column = 45 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 23467525
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 76, column = 5 }, end = { row = 76, column = 16 } }
                                , category = "declaration"
                                }
                              )
                            , ( 182652811
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 27, column = 18 }, end = { row = 27, column = 24 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 353199476
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 10, column = 26 }, end = { row = 10, column = 31 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 357133973
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 6, column = 10 }, end = { row = 6, column = 21 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 421798468
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 27, column = 13 }, end = { row = 31, column = 22 } }
                                , category = "declaration"
                                }
                              )
                            , ( 431196966
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 29, column = 21 }, end = { row = 29, column = 24 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 662760606
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 70, column = 25 }, end = { row = 70, column = 44 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 798163806
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 31, column = 21 }, end = { row = 31, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 954960163
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 52, column = 13 }, end = { row = 56, column = 22 } }
                                , category = "declaration"
                                }
                              )
                            , ( 960691989
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 20, column = 13 }, end = { row = 20, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 984664282
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 43, column = 17 }, end = { row = 43, column = 18 } }
                                , category = "if-branch"
                                }
                              )
                            , ( 1146639121
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 62, column = 25 }, end = { row = 62, column = 41 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1479773536
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 56, column = 21 }, end = { row = 56, column = 22 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1503310822
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "ifInLet"
                                , range = { start = { row = 40, column = 13 }, end = { row = 43, column = 18 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1698499172
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "caseInLet"
                                , range = { start = { row = 33, column = 5 }, end = { row = 33, column = 10 } }
                                , category = "declaration"
                                }
                              )
                            , ( 1161055252
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 14, column = 29 }, end = { row = 14, column = 34 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1210665696
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 60, column = 22 }, end = { row = 60, column = 27 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2001614685
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 72, column = 25 }, end = { row = 72, column = 43 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 329579790
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 72, column = 25 }, end = { row = 72, column = 43 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1111335368
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 74, column = 25 }, end = { row = 74, column = 45 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1337164990
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 16, column = 29 }, end = { row = 16, column = 36 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 1386782202
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 64, column = 25 }, end = { row = 64, column = 40 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 329579790
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 68, column = 22 }, end = { row = 68, column = 27 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1479773536
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 60, column = 22 }, end = { row = 60, column = 27 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1503310822
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 52, column = 18 }, end = { row = 52, column = 28 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1615377089
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 8, column = 18 }, end = { row = 8, column = 24 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 1698499172
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "complexNested"
                                , range = { start = { row = 52, column = 18 }, end = { row = 52, column = 28 } }
                                , category = "subexpression"
                                }
                              )
                            , ( 2069063037
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 12, column = 29 }, end = { row = 12, column = 35 } }
                                , category = "case-branch"
                                }
                              )
                            , ( 2130358651
                              , { moduleName = "NestedLetCaseIf"
                                , moduleFilePath = "NestedLetCaseIf.elm"
                                , declarationName = "nestedCaseOf"
                                , range = { start = { row = 18, column = 21 }, end = { row = 18, column = 37 } }
                                , category = "case-branch"
                                }
                              )
                            ]
                    , contentHash = 862151992
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
