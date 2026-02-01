module EndToEndTests exposing (suite)

import Dict
import Expect
import FNV1a
import Fuzz exposing (Fuzzer)
import Main
import Range exposing (Position, Range)
import Test exposing (Test)


type alias TestCase =
    { name : String
    , input : Main.Input
    , output : Main.Output
    }


suite : Test
suite =
    Test.describe "End to end tests" <|
        List.concat <|
            [ [ Test.fuzz
                    (fuzzInput "stdout")
                    "stdout format - same as plaintext"
                    (\input ->
                        let
                            plaintextInput =
                                { input | format = "plaintext" }

                            stdoutResult =
                                Main.work input

                            plaintextResult =
                                Main.work plaintextInput
                        in
                        case ( stdoutResult, plaintextResult ) of
                            ( Ok stdout, Ok plaintext ) ->
                                let
                                    stdoutContents =
                                        List.map .contents stdout.reports

                                    plaintextContents =
                                        List.map .contents plaintext.reports
                                in
                                Expect.equal stdoutContents plaintextContents

                            ( Err stdoutErr, Err plaintextErr ) ->
                                Expect.equal stdoutErr plaintextErr

                            _ ->
                                Expect.fail "One format succeeded while the other failed"
                    )
              ]
            , [ { name = "plaintext format - basic"
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
                     , moduleHashes =
                         Dict.fromList
                             [ ( "A", FNV1a.hash "module A" )
                             ]
                     , format = "plaintext"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "coverage.txt"
                               , contents = """Total: 1/2 (50%)
A: 1/2 (50%)"""
                               }
                             ]
                         }
                }
              , { name = "html format - single module"
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
                     , moduleHashes =
                         Dict.fromList
                             [ ( "A", FNV1a.hash """module A
a = 1""" )
                             ]
                     , format = "html"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "index.html"
                               , contents = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<div><h1>Coverage Report</h1><table><thead><tr><th>Module</th><th>Coverage</th></tr></thead><tbody><tr><td><a href="A.html">A</a></td><td>1 / 1 (100%)</td></tr></tbody></table></div>
</html>"""
                               }
                             , { filepath = "A.html"
                               , contents = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>A - Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        td { border: none; padding: 2px; }
        .line-number { text-align: right; padding-right: 10px; color: #666; user-select: none; }
        .covered { 
            background-color: #d4edda; 
            border-radius: 6px; 
            position: relative;
        }
        .covered:hover { background-color: rgba(212, 237, 218, 0.25); outline: 2px solid #d4edda; }
        .uncovered { 
            background-color: #f8d7da; 
            border-radius: 6px; 
            position: relative;
        }
        .uncovered:hover { background-color: rgba(248, 215, 218, 0.25); outline: 2px solid #f8d7da; }
        .no-coverage { background-color: transparent; }
        pre { margin: 0; font-family: monospace; white-space: pre-wrap; position: relative; }
        .tooltip { 
            display: none;
            background-color: #333;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            white-space: nowrap;
            z-index: 1000;
            pointer-events: none;
            position: absolute;
            /* Pure CSS positioning: center above the parent span */
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            margin-bottom: 4px;
        }
        .covered:hover .tooltip,
        .uncovered:hover .tooltip {
            display: block;
        }
    </style>
</head>
<div><h1>A</h1><p><a href="index.html">← Back to index</a></p><table><tr><td style="text-align: right; padding-right: 10px; color: #666; user-select: none">1</td><td><pre style="margin: 0; font-family: monospace"><span><span class="covered">modul<span class="tooltip">1x</span></span><span class="no-coverage">e A</span></span></pre></td></tr><tr><td style="text-align: right; padding-right: 10px; color: #666; user-select: none">2</td><td><pre style="margin: 0; font-family: monospace">a = 1</pre></td></tr></table></div>
</html>"""
                               }
                             ]
                         }
                }
              , { name = "html format - uncovered regions"
                , input =
                     { coverageMetadata =
                         Dict.fromList
                             [ ( 1
                               , { moduleName = "A"
                                 , declarationName = "a"
                                 , range = { start = { row = 2, column = 1 }, end = { row = 2, column = 5 } }
                                 }
                               )
                             , ( 2
                               , { moduleName = "A"
                                 , declarationName = "b"
                                 , range = { start = { row = 3, column = 1 }, end = { row = 3, column = 5 } }
                                 }
                               )
                             ]
                     , coverageData = Dict.fromList [ ( 1, 5 ), ( 2, 0 ) ]
                     , sources = Dict.fromList [ ( "A", """module A
a = 1
b = 2""" ) ]
                     , moduleHashes =
                         Dict.fromList
                             [ ( "A", FNV1a.hash """module A
a = 1
b = 2""" )
                             ]
                     , format = "html"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "index.html"
                               , contents = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<div><h1>Coverage Report</h1><table><thead><tr><th>Module</th><th>Coverage</th></tr></thead><tbody><tr><td><a href="A.html">A</a></td><td>1 / 2 (50%)</td></tr></tbody></table></div>
</html>"""
                               }
                             , { filepath = "A.html"
                               , contents = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>A - Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        td { border: none; padding: 2px; }
        .line-number { text-align: right; padding-right: 10px; color: #666; user-select: none; }
        .covered { 
            background-color: #d4edda; 
            border-radius: 6px; 
            position: relative;
        }
        .covered:hover { background-color: rgba(212, 237, 218, 0.25); outline: 2px solid #d4edda; }
        .uncovered { 
            background-color: #f8d7da; 
            border-radius: 6px; 
            position: relative;
        }
        .uncovered:hover { background-color: rgba(248, 215, 218, 0.25); outline: 2px solid #f8d7da; }
        .no-coverage { background-color: transparent; }
        pre { margin: 0; font-family: monospace; white-space: pre-wrap; position: relative; }
        .tooltip { 
            display: none;
            background-color: #333;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            white-space: nowrap;
            z-index: 1000;
            pointer-events: none;
            position: absolute;
            /* Pure CSS positioning: center above the parent span */
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            margin-bottom: 4px;
        }
        .covered:hover .tooltip,
        .uncovered:hover .tooltip {
            display: block;
        }
    </style>
</head>
<div><h1>A</h1><p><a href="index.html">← Back to index</a></p><table><tr><td style="text-align: right; padding-right: 10px; color: #666; user-select: none">1</td><td><pre style="margin: 0; font-family: monospace">module A</pre></td></tr><tr><td style="text-align: right; padding-right: 10px; color: #666; user-select: none">2</td><td><pre style="margin: 0; font-family: monospace"><span><span class="covered">a = 1<span class="tooltip">5x</span></span></span></pre></td></tr><tr><td style="text-align: right; padding-right: 10px; color: #666; user-select: none">3</td><td><pre style="margin: 0; font-family: monospace"><span><span class="uncovered">b = 2<span class="tooltip">0x</span></span></span></pre></td></tr></table></div>
</html>"""
                               }
                             ]
                         }
                }
              , { name = "html format - nested boolean expression"
                , input =
                     { coverageMetadata =
                         Dict.fromList
                             [ ( 1
                               , { moduleName = "A"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 5 }, end = { row = 4, column = 16 } }
                                 }
                               )
                             , ( 2
                               , { moduleName = "A"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 5 }, end = { row = 4, column = 6 } }
                                 }
                               )
                             , ( 3
                               , { moduleName = "A"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 10 }, end = { row = 4, column = 16 } }
                                 }
                               )
                             , ( 4
                               , { moduleName = "A"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 10 }, end = { row = 4, column = 11 } }
                                 }
                               )
                             , ( 5
                               , { moduleName = "A"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 15 }, end = { row = 4, column = 16 } }
                                 }
                               )
                             ]
                     , coverageData = Dict.fromList
                         [ ( 1, 10 )
                         , ( 2, 10 )
                         , ( 3, 8 )
                         , ( 4, 8 )
                         , ( 5, 5 )
                         ]
                     , sources = Dict.fromList
                         [ ( "A", """module A exposing (a)

a =
    a && b && c""" )
                         ]
                     , moduleHashes =
                         Dict.fromList
                             [ ( "A", FNV1a.hash """module A exposing (a)

a =
    a && b && c""" )
                             ]
                     , format = "html"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "index.html"
                               , contents = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<div><h1>Coverage Report</h1><table><thead><tr><th>Module</th><th>Coverage</th></tr></thead><tbody><tr><td><a href="A.html">A</a></td><td>5 / 5 (100%)</td></tr></tbody></table></div>
</html>"""
                               }
                             , { filepath = "A.html"
                               , contents = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>A - Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        td { border: none; padding: 2px; }
        .line-number { text-align: right; padding-right: 10px; color: #666; user-select: none; }
        .covered { 
            background-color: #d4edda; 
            border-radius: 6px; 
            position: relative;
        }
        .covered:hover { background-color: rgba(212, 237, 218, 0.25); outline: 2px solid #d4edda; }
        .uncovered { 
            background-color: #f8d7da; 
            border-radius: 6px; 
            position: relative;
        }
        .uncovered:hover { background-color: rgba(248, 215, 218, 0.25); outline: 2px solid #f8d7da; }
        .no-coverage { background-color: transparent; }
        pre { margin: 0; font-family: monospace; white-space: pre-wrap; position: relative; }
        .tooltip { 
            display: none;
            background-color: #333;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            white-space: nowrap;
            z-index: 1000;
            pointer-events: none;
            position: absolute;
            /* Pure CSS positioning: center above the parent span */
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            margin-bottom: 4px;
        }
        .covered:hover .tooltip,
        .uncovered:hover .tooltip {
            display: block;
        }
    </style>
</head>
<div><h1>A</h1><p><a href="index.html">← Back to index</a></p><table><tr><td style="text-align: right; padding-right: 10px; color: #666; user-select: none">1</td><td><pre style="margin: 0; font-family: monospace">module A exposing (a)</pre></td></tr><tr><td style="text-align: right; padding-right: 10px; color: #666; user-select: none">2</td><td><pre style="margin: 0; font-family: monospace"></pre></td></tr><tr><td style="text-align: right; padding-right: 10px; color: #666; user-select: none">3</td><td><pre style="margin: 0; font-family: monospace">a =</pre></td></tr><tr><td style="text-align: right; padding-right: 10px; color: #666; user-select: none">4</td><td><pre style="margin: 0; font-family: monospace"><span><span class="no-coverage">    </span><span class="covered">a &amp;&amp; <span class="tooltip">10x</span></span><span class="covered">b &amp;&amp; <span class="tooltip">8x</span></span><span class="covered">c<span class="tooltip">5x</span></span></span></pre></td></tr></table></div>
</html>"""
                               }
                             ]
                         }
                }
              -- TODO: add test for LCOV format
              , { name = "csv format"
                , input =
                     { coverageMetadata = Dict.empty
                     , coverageData = Dict.empty
                     , sources = Dict.empty
                     , moduleHashes = Dict.empty
                     , format = "csv"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "coverage.csv", contents = """Module,Covered,Total,Percentage
Total,0,0,0""" }
                             ]
                         }
                }
              , { name = "csv format - with coverage data"
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
                             , ( 4
                               , { moduleName = "C"
                                 , declarationName = "d"
                                 , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                                 }
                               )
                             ]
                     , coverageData = Dict.fromList [ ( 1, 1 ), ( 2, 0 ), ( 3, 1 ), ( 4, 0 ) ]
                     , sources = Dict.fromList [ ( "A", "module A" ), ( "B", "module B" ), ( "C", "module C" ) ]
                     , moduleHashes =
                         Dict.fromList
                             [ ( "A", FNV1a.hash "module A" )
                             , ( "B", FNV1a.hash "module B" )
                             , ( "C", FNV1a.hash "module C" )
                             ]
                     , format = "csv"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "coverage.csv"
                               , contents = """Module,Covered,Total,Percentage
Total,2,4,50
A,1,2,50
B,1,1,100
C,0,1,0"""
                               }
                             ]
                         }
                }
              , { name = "hash mismatch error"
                , input =
                     { coverageMetadata = Dict.empty
                     , coverageData = Dict.empty
                     , sources = Dict.fromList [ ( "A", "module A" ) ]
                     , moduleHashes = Dict.fromList [ ( "A", 999999 ) ]
                     , format = "plaintext"
                     }
                , output =
                     Err "Content hash mismatch for modules: A"
                }
              , { name = "unsupported format error"
                , input =
                     { coverageMetadata = Dict.empty
                     , coverageData = Dict.empty
                     , sources = Dict.empty
                     , moduleHashes = Dict.empty
                     , format = "unknown"
                     }
                , output =
                     Err "Unsupported format: unknown"
                }
              , { name = "missing module hash"
                , input =
                     { coverageMetadata = Dict.empty
                     , coverageData = Dict.empty
                     , sources = Dict.fromList [ ( "A", "module A" ) ]
                     , moduleHashes = Dict.empty
                     , format = "plaintext"
                     }
                , output =
                     Err "Content hash mismatch for modules: A"
                }
              ]
                |> List.map testCase
            ]


testCase : TestCase -> Test
testCase tc =
    Test.test tc.name <|
        \() ->
            Main.work tc.input
                |> Expect.equal tc.output


moduleNameFuzzer : Fuzzer String
moduleNameFuzzer =
    Fuzz.string
        |> Fuzz.map (\s -> "Module" ++ String.slice 0 10 s)


sourceFuzzer : Fuzzer String
sourceFuzzer =
    Fuzz.string
        |> Fuzz.map (\s -> "module " ++ String.slice 0 20 s)


positionFuzzer : Fuzzer Position
positionFuzzer =
    Fuzz.map2 Position
        (Fuzz.intRange 1 100)
        (Fuzz.intRange 1 100)


rangeFuzzer : Fuzzer Range
rangeFuzzer =
    Fuzz.map2 Range
        positionFuzzer
        positionFuzzer


coverageCountFuzzer : Fuzzer Int
coverageCountFuzzer =
    Fuzz.intRange 0 10


pointFuzzer : Fuzzer ( Int, Range, Int )
pointFuzzer =
    Fuzz.map3
        (\pointId range count ->
            ( pointId, range, count )
        )
        (Fuzz.intRange 0 1000)
        rangeFuzzer
        coverageCountFuzzer


fuzzInput : String -> Fuzzer Main.Input
fuzzInput format =
    Fuzz.map3
        (\moduleName source points ->
            let
                ( coverageMetadataList, coverageDataList ) =
                    points
                        |> List.map
                            (\( pointId, range, count ) ->
                                ( ( pointId
                                  , { moduleName = moduleName
                                    , declarationName = "decl" ++ String.fromInt pointId
                                    , range = range
                                    }
                                  )
                                , ( pointId, count )
                                )
                            )
                        |> List.unzip

                coverageMetadata =
                    Dict.fromList coverageMetadataList

                coverageData =
                    Dict.fromList coverageDataList

                moduleHashes =
                    Dict.fromList [ ( moduleName, FNV1a.hash source ) ]
            in
            { coverageMetadata = coverageMetadata
            , coverageData = coverageData
            , sources = Dict.fromList [ ( moduleName, source ) ]
            , moduleHashes = moduleHashes
            , format = format
            }
        )
        moduleNameFuzzer
        sourceFuzzer
        (Fuzz.list pointFuzzer)
