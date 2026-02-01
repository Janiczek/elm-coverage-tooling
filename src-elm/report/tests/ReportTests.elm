module ReportTests exposing (suite)

import Dict exposing (Dict)
import Expect
import Format exposing (Format(..), fromString)
import PointMetadata exposing (PointMetadata)
import Range exposing (Position, Range)
import Report exposing (Input, ReportFile)
import Report.Csv
import Report.Html
import Report.Lcov
import Report.Plaintext
import Report.Stdout
import Test exposing (Test)




type alias TestCase =
    { name : String
    , input : Input
    , checkOutput : { reports : List ReportFile } -> Bool
    }


suite : Test
suite =
    Test.describe "Report tests"
        ([ { name = "generatePlaintext - basic coverage"
           , input =
                { coverageMetadata =
                    Dict.fromList
                        [ ( 1
                          , { moduleName = "A"
                            , declarationName = "a"
                            , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                            }
                          )
                        , ( 2
                          , { moduleName = "A"
                            , declarationName = "b"
                            , range = { start = { row = 2, column = 1 }, end = { row = 2, column = 5 } }
                            }
                          )
                        ]
                , coverageData = Dict.fromList [ ( 1, 1 ), ( 2, 0 ) ]
                , sources = Dict.fromList [ ( "A", "module A" ) ]
                , moduleHashes = Dict.fromList [ ( "A", 0 ) ]
                , format = "plaintext"
                }
           , checkOutput =
                \output ->
                    List.length output.reports == 1
                        && (case List.head output.reports of
                                Just report ->
                                    report.filepath == "coverage.txt"
                                        && String.contains "Total: 1/2 (50%)" report.contents
                                        && String.contains "A: 1/2 (50%)" report.contents

                                Nothing ->
                                    False
                           )
           }
         , { name = "generatePlaintext - 100% coverage"
           , input =
                { coverageMetadata =
                    Dict.fromList
                        [ ( 1
                          , { moduleName = "A"
                            , declarationName = "a"
                            , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                            }
                          )
                        ]
                , coverageData = Dict.fromList [ ( 1, 5 ) ]
                , sources = Dict.fromList [ ( "A", "module A" ) ]
                , moduleHashes = Dict.fromList [ ( "A", 0 ) ]
                , format = "plaintext"
                }
           , checkOutput =
                \output ->
                    case List.head output.reports of
                        Just report ->
                            String.contains "Total: 1/1 (100%)" report.contents
                                && String.contains "A: 1/1 (100%)" report.contents

                        Nothing ->
                            False
           }
         , { name = "generatePlaintext - 0% coverage"
           , input =
                { coverageMetadata =
                    Dict.fromList
                        [ ( 1
                          , { moduleName = "A"
                            , declarationName = "a"
                            , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                            }
                          )
                        ]
                , coverageData = Dict.fromList [ ( 1, 0 ) ]
                , sources = Dict.fromList [ ( "A", "module A" ) ]
                , moduleHashes = Dict.fromList [ ( "A", 0 ) ]
                , format = "plaintext"
                }
           , checkOutput =
                \output ->
                    case List.head output.reports of
                        Just report ->
                            String.contains "Total: 0/1 (0%)" report.contents
                                && String.contains "A: 0/1 (0%)" report.contents

                        Nothing ->
                            False
           }
         , { name = "generateHtml - single module"
           , input =
                { coverageMetadata =
                    Dict.fromList
                        [ ( 1
                          , { moduleName = "A"
                            , declarationName = "a"
                            , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                            }
                          )
                        ]
                , coverageData = Dict.fromList [ ( 1, 1 ) ]
                , sources = Dict.fromList [ ( "A", """module A
a = 1""" ) ]
                , moduleHashes = Dict.fromList [ ( "A", 0 ) ]
                , format = "html"
                }
           , checkOutput =
                \output ->
                    List.length output.reports >= 2
                        && List.any (\r -> r.filepath == "index.html") output.reports
                        && List.any (\r -> r.filepath == "A.html") output.reports
                        && (case List.filter (\r -> r.filepath == "index.html") output.reports of
                                [ index ] ->
                                    String.contains "A" index.contents
                                        && String.contains "<table>" index.contents

                                _ ->
                                    False
                           )
           }
         , { name = "generateHtml - multiple modules"
           , input =
                { coverageMetadata =
                    Dict.fromList
                        [ ( 1
                          , { moduleName = "A"
                            , declarationName = "a"
                            , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                            }
                          )
                        , ( 2
                          , { moduleName = "B"
                            , declarationName = "b"
                            , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                            }
                          )
                        ]
                , coverageData = Dict.fromList [ ( 1, 1 ), ( 2, 0 ) ]
                , sources = Dict.fromList [ ( "A", "module A" ), ( "B", "module B" ) ]
                , moduleHashes = Dict.fromList [ ( "A", 0 ), ( "B", 0 ) ]
                , format = "html"
                }
           , checkOutput =
                \output ->
                    List.length output.reports >= 3
                        && List.any (\r -> r.filepath == "index.html") output.reports
                        && List.any (\r -> r.filepath == "A.html") output.reports
                        && List.any (\r -> r.filepath == "B.html") output.reports
           }
         , { name = "generateLcov - placeholder"
           , input =
                { coverageMetadata = Dict.empty
                , coverageData = Dict.empty
                , sources = Dict.empty
                , moduleHashes = Dict.empty
                , format = "lcov"
                }
           , checkOutput =
                \output ->
                    List.length output.reports == 1
                        && (case List.head output.reports of
                                Just report ->
                                    report.filepath == "coverage.lcov"

                                Nothing ->
                                    False
                           )
           }
         , { name = "generateCsv - empty coverage"
           , input =
                { coverageMetadata = Dict.empty
                , coverageData = Dict.empty
                , sources = Dict.empty
                , moduleHashes = Dict.empty
                , format = "csv"
                }
           , checkOutput =
                \output ->
                    List.length output.reports == 1
                        && (case List.head output.reports of
                                Just report ->
                                    report.filepath == "coverage.csv"
                                        && String.contains "Module,Covered,Total,Percentage" report.contents
                                        && String.contains "Total,0,0,0" report.contents

                                Nothing ->
                                    False
                           )
           }
         , { name = "generateCsv - with coverage data"
           , input =
                { coverageMetadata =
                    Dict.fromList
                        [ ( 1
                          , { moduleName = "A"
                            , declarationName = "a"
                            , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                            }
                          )
                        , ( 2
                          , { moduleName = "A"
                            , declarationName = "b"
                            , range = { start = { row = 2, column = 1 }, end = { row = 2, column = 5 } }
                            }
                          )
                        , ( 3
                          , { moduleName = "B"
                            , declarationName = "c"
                            , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                            }
                          )
                        ]
                , coverageData = Dict.fromList [ ( 1, 1 ), ( 2, 0 ), ( 3, 1 ) ]
                , sources = Dict.fromList [ ( "A", "module A" ), ( "B", "module B" ) ]
                , moduleHashes = Dict.fromList [ ( "A", 0 ), ( "B", 0 ) ]
                , format = "csv"
                }
           , checkOutput =
                \output ->
                    List.length output.reports == 1
                        && (case List.head output.reports of
                                Just report ->
                                    report.filepath == "coverage.csv"
                                        && String.contains "Module,Covered,Total,Percentage" report.contents
                                        && String.contains "Total,2,3," report.contents
                                        && String.contains "A,1,2," report.contents
                                        && String.contains "B,1,1," report.contents

                                Nothing ->
                                    False
                           )
           }
         , { name = "generateStdout - reuses plaintext format"
           , input =
                { coverageMetadata =
                    Dict.fromList
                        [ ( 1
                          , { moduleName = "A"
                            , declarationName = "a"
                            , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                            }
                          )
                        , ( 2
                          , { moduleName = "A"
                            , declarationName = "b"
                            , range = { start = { row = 2, column = 1 }, end = { row = 2, column = 5 } }
                            }
                          )
                        ]
                , coverageData = Dict.fromList [ ( 1, 1 ), ( 2, 0 ) ]
                , sources = Dict.fromList [ ( "A", "module A" ) ]
                , moduleHashes = Dict.fromList [ ( "A", 0 ) ]
                , format = "stdout"
                }
           , checkOutput =
                \output ->
                    List.length output.reports == 1
                        && (case List.head output.reports of
                                Just report ->
                                    report.filepath == "stdout"
                                        && String.contains "Total: 1/2 (50%)" report.contents
                                        && String.contains "A: 1/2 (50%)" report.contents

                                Nothing ->
                                    False
                           )
           }
         ]
            |> List.map testCase
        )


testCase : TestCase -> Test
testCase tc =
    Test.test tc.name <|
        \() ->
            let
                result =
                    case fromString tc.input.format of
                        Just Html ->
                            Report.Html.generate tc.input

                        Just Plaintext ->
                            Report.Plaintext.generate tc.input

                        Just Stdout ->
                            Report.Stdout.generate tc.input

                        Just Lcov ->
                            Report.Lcov.generate tc.input

                        Just Csv ->
                            Report.Csv.generate tc.input

                        Nothing ->
                            { reports = [] }
            in
            if tc.checkOutput result then
                Expect.pass

            else
                Expect.fail "Output did not match expected pattern"
