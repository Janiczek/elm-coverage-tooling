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
