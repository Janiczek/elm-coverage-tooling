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
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 5, column = 8 } }
                                }
                              )
                            ]
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
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 5, column = 8 } }
                                }
                              )
                            ]
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


a : Int
a =
    let
        _ =
            Test.Coverage.track 107558697
    in
    (let
        _ =
            Test.Coverage.track 154242004
     in
     1
    )
        + (let
            _ =
                Test.Coverage.track 1751612961
           in
           2
          )
"""
                    , coverageMetadata =
                        Dict.fromList
                            [ ( 107558697
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 5, column = 10 } }
                                }
                              )
                            , ( 154242004
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 5, column = 6 } }
                                }
                              )
                            , ( 1751612961
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 9 }, end = { row = 5, column = 10 } }
                                }
                              )
                            ]
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


a : Int
a =
    let
        _ =
            Test.Coverage.track
                1004572879
    in
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
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 8 }, end = { row = 5, column = 21 } }
                                }
                              )
                            , ( 154242004
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 8 }, end = { row = 5, column = 12 } }
                                }
                              )
                            , ( 434548591
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 8, column = 9 }, end = { row = 8, column = 10 } }
                                }
                              )
                            , ( 1004572879
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 8, column = 10 } }
                                }
                              )
                            , ( 1751612961
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 16 }, end = { row = 5, column = 21 } }
                                }
                              )
                            , ( 1885435985
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 6, column = 9 }, end = { row = 6, column = 10 } }
                                }
                              )
                            ]
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


a : Int
a =
    let
        _ =
            Test.Coverage.track
                434548591
    in
    case let
            _ =
                Test.Coverage.track 154242004
        in
        2 of
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
                                , declarationName = "a"
                                , range = { start = { row = 7, column = 14 }, end = { row = 7, column = 17 } }
                                }
                              )
                            , ( 154242004
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 10 }, end = { row = 5, column = 11 } }
                                }
                              )
                            , ( 434548591
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 5, column = 5 }, end = { row = 8, column = 16 } }
                                }
                              )
                            , ( 1751612961
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 6, column = 14 }, end = { row = 6, column = 17 } }
                                }
                              )
                            , ( 1885435985
                              , { moduleName = "A"
                                , declarationName = "a"
                                , range = { start = { row = 8, column = 15 }, end = { row = 8, column = 16 } }
                                }
                              )
                            ]
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
