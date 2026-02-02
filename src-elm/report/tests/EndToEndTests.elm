module EndToEndTests exposing (suite)

import Dict
import Expect
import FNV1a
import Fuzz exposing (Fuzzer)
import Main
import Range exposing (Position, Range)
import Test exposing (Test)


stripAnsiCodes : String -> String
stripAnsiCodes text =
    -- Remove ANSI escape sequences: \u001b[ followed by numbers/semicolons and ending with m
    -- Simple recursive approach to strip ANSI codes
    stripAnsiCodesHelper text ""


stripAnsiCodesHelper : String -> String -> String
stripAnsiCodesHelper remaining acc =
    case String.uncons remaining of
        Nothing ->
            acc

        Just ( char, rest ) ->
            if char == '\u{001B}' then
                -- Found ESC, skip until 'm'
                skipUntilM rest acc

            else
                stripAnsiCodesHelper rest (acc ++ String.fromChar char)


skipUntilM : String -> String -> String
skipUntilM remaining acc =
    case String.uncons remaining of
        Nothing ->
            acc

        Just ( char, rest ) ->
            if char == 'm' then
                -- Found 'm', continue stripping
                stripAnsiCodesHelper rest acc

            else
                -- Continue skipping
                skipUntilM rest acc


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
                    "stdout format - same as plaintext (after stripping ANSI codes)"
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
                                        List.map (.contents >> stripAnsiCodes) stdout.reports

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
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             , ( 2
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "b"
                                 , range = { start = { row = 2, column = 1 }, end = { row = 2, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             ]
                     , coverageData = Dict.fromList [ ( 1, 1 ), ( 2, 0 ) ]
                     , sources = Dict.fromList [ ( "src/A.elm", "module A" ) ]
                     , moduleHashes =
                         Dict.fromList
                             [ ( "src/A.elm", FNV1a.hash "module A" )
                             ]
                     , moduleNames = Dict.fromList [ ( "src/A.elm", "A" ) ]
                     , format = "plaintext"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "coverage.txt"
                               , contents = """File       Total    %  Declaration (c/t/%)  Subexpression (c/t/%)       Lambda (c/t/%)    If-branch (c/t/%)  Case-branch (c/t/%)
--------------------------------------------------------------------------------------------------------------------------------
src/A.elm    1/2  50%              1/2 50%               0/0 0%               0/0 0%               0/0 0%               0/0 0%
--------------------------------------------------------------------------------------------------------------------------------
Total        1/2  50%              1/2 50%               0/0 0%               0/0 0%               0/0 0%               0/0 0%"""
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
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             ]
                     , coverageData = Dict.fromList [ ( 1, 1 ) ]
                     , sources = Dict.fromList [ ( "src/A.elm", """module A
a = 1""" ) ]
                     , moduleHashes =
                         Dict.fromList
                             [ ( "src/A.elm", FNV1a.hash """module A
a = 1""" )
                             ]
                     , moduleNames = Dict.fromList [ ( "src/A.elm", "A" ) ]
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
<div><h1>Coverage Report</h1><table><thead><tr><th>Module</th><th>Total</th><th>Declaration</th><th>Subexpression</th><th>Lambda</th><th>If-branch</th><th>Case-branch</th></tr></thead><tbody><tr><td><a href="src/A.html">src/A.elm</a></td><td style="background-color: #CCFFCC">1 / 1 (100%)</td><td style="background-color: #CCFFCC">1 / 1 (100%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td></tr><tr><td style="font-weight: bold">Total</td><td style="background-color: #CCFFCC">1 / 1 (100%)</td><td style="background-color: #CCFFCC">1 / 1 (100%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td></tr></tbody></table></div>
</html>"""
                               }
                             , { filepath = "src/A.html"
                               , contents = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>src/A.elm - Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        table.summary-table { margin-bottom: 20px; }
        table.summary-table th, table.summary-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        table.summary-table th { background-color: #f2f2f2; }
        table.source-table td { border: none; padding: 0; line-height: 1.15; }
        table.source-table tr td:first-child { width: 1%; white-space: nowrap; padding-right: 8px; }
        .line-number { text-align: right; color: #666; user-select: none; }
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
        td:first-child {
            font-family: "JetBrains Mono", monospace; 
            text-align: right;
            color: #666;
            user-select: none;
            font-size: inherit;
        }
        pre { 
            margin: 0; 
            font-family: "JetBrains Mono", monospace; 
            white-space: pre-wrap;
            position: relative; 
        }
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
<div><h1>src/A.elm</h1><p><a href="../index.html">← Back to index</a></p><table class="summary-table"><thead><tr><th>Category</th><th>Total</th><th>Declaration</th><th>Subexpression</th><th>Lambda</th><th>If-branch</th><th>Case-branch</th></tr></thead><tbody><tr><td>Total</td><td style="background-color: #CCFFCC">1 / 1 (100%)</td><td style="background-color: #CCFFCC">1 / 1 (100%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td></tr></tbody></table><table class="source-table"><tr><td>1</td><td><pre><span><span class="covered">modul<span class="tooltip">1x</span></span><span class="no-coverage">e A</span></span></pre></td></tr><tr><td>2</td><td><pre>a = 1</pre></td></tr></table></div>
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
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 2, column = 1 }, end = { row = 2, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             , ( 2
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "b"
                                 , range = { start = { row = 3, column = 1 }, end = { row = 3, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             ]
                     , coverageData = Dict.fromList [ ( 1, 5 ), ( 2, 0 ) ]
                     , sources = Dict.fromList [ ( "src/A.elm", """module A
a = 1
b = 2""" ) ]
                     , moduleHashes =
                         Dict.fromList
                             [ ( "src/A.elm", FNV1a.hash """module A
a = 1
b = 2""" )
                             ]
                     , moduleNames = Dict.fromList [ ( "src/A.elm", "A" ) ]
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
<div><h1>Coverage Report</h1><table><thead><tr><th>Module</th><th>Total</th><th>Declaration</th><th>Subexpression</th><th>Lambda</th><th>If-branch</th><th>Case-branch</th></tr></thead><tbody><tr><td><a href="src/A.html">src/A.elm</a></td><td style="background-color: #FFFFCC">1 / 2 (50%)</td><td style="background-color: #FFFFCC">1 / 2 (50%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td></tr><tr><td style="font-weight: bold">Total</td><td style="background-color: #FFFFCC">1 / 2 (50%)</td><td style="background-color: #FFFFCC">1 / 2 (50%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td></tr></tbody></table></div>
</html>"""
                               }
                             , { filepath = "src/A.html"
                               , contents = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>src/A.elm - Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        table.summary-table { margin-bottom: 20px; }
        table.summary-table th, table.summary-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        table.summary-table th { background-color: #f2f2f2; }
        table.source-table td { border: none; padding: 0; line-height: 1.15; }
        table.source-table tr td:first-child { width: 1%; white-space: nowrap; padding-right: 8px; }
        .line-number { text-align: right; color: #666; user-select: none; }
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
        td:first-child {
            font-family: "JetBrains Mono", monospace; 
            text-align: right;
            color: #666;
            user-select: none;
            font-size: inherit;
        }
        pre { 
            margin: 0; 
            font-family: "JetBrains Mono", monospace; 
            white-space: pre-wrap;
            position: relative; 
        }
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
<div><h1>src/A.elm</h1><p><a href="../index.html">← Back to index</a></p><table class="summary-table"><thead><tr><th>Category</th><th>Total</th><th>Declaration</th><th>Subexpression</th><th>Lambda</th><th>If-branch</th><th>Case-branch</th></tr></thead><tbody><tr><td>Total</td><td style="background-color: #FFFFCC">1 / 2 (50%)</td><td style="background-color: #FFFFCC">1 / 2 (50%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td></tr></tbody></table><table class="source-table"><tr><td>1</td><td><pre>module A</pre></td></tr><tr><td>2</td><td><pre><span><span class="covered">a = 1<span class="tooltip">5x</span></span></span></pre></td></tr><tr><td>3</td><td><pre><span><span class="uncovered">b = 2<span class="tooltip">0x</span></span></span></pre></td></tr></table></div>
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
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 5 }, end = { row = 4, column = 16 } }
                                 , category = "declaration"
                                 }
                               )
                             , ( 2
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 5 }, end = { row = 4, column = 6 } }
                                 , category = "subexpression"
                                 }
                               )
                             , ( 3
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 10 }, end = { row = 4, column = 16 } }
                                 , category = "subexpression"
                                 }
                               )
                             , ( 4
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 10 }, end = { row = 4, column = 11 } }
                                 , category = "subexpression"
                                 }
                               )
                             , ( 5
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 4, column = 15 }, end = { row = 4, column = 16 } }
                                 , category = "subexpression"
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
                         [ ( "src/A.elm", """module A exposing (a)

a =
    a && b && c""" )
                         ]
                     , moduleHashes =
                         Dict.fromList
                             [ ( "src/A.elm", FNV1a.hash """module A exposing (a)

a =
    a && b && c""" )
                             ]
                     , moduleNames = Dict.fromList [ ( "src/A.elm", "A" ) ]
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
<div><h1>Coverage Report</h1><table><thead><tr><th>Module</th><th>Total</th><th>Declaration</th><th>Subexpression</th><th>Lambda</th><th>If-branch</th><th>Case-branch</th></tr></thead><tbody><tr><td><a href="src/A.html">src/A.elm</a></td><td style="background-color: #CCFFCC">5 / 5 (100%)</td><td style="background-color: #CCFFCC">1 / 1 (100%)</td><td style="background-color: #CCFFCC">4 / 4 (100%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td></tr><tr><td style="font-weight: bold">Total</td><td style="background-color: #CCFFCC">5 / 5 (100%)</td><td style="background-color: #CCFFCC">1 / 1 (100%)</td><td style="background-color: #CCFFCC">4 / 4 (100%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td></tr></tbody></table></div>
</html>"""
                               }
                             , { filepath = "src/A.html"
                               , contents = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>src/A.elm - Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        table.summary-table { margin-bottom: 20px; }
        table.summary-table th, table.summary-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        table.summary-table th { background-color: #f2f2f2; }
        table.source-table td { border: none; padding: 0; line-height: 1.15; }
        table.source-table tr td:first-child { width: 1%; white-space: nowrap; padding-right: 8px; }
        .line-number { text-align: right; color: #666; user-select: none; }
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
        td:first-child {
            font-family: "JetBrains Mono", monospace; 
            text-align: right;
            color: #666;
            user-select: none;
            font-size: inherit;
        }
        pre { 
            margin: 0; 
            font-family: "JetBrains Mono", monospace; 
            white-space: pre-wrap;
            position: relative; 
        }
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
<div><h1>src/A.elm</h1><p><a href="../index.html">← Back to index</a></p><table class="summary-table"><thead><tr><th>Category</th><th>Total</th><th>Declaration</th><th>Subexpression</th><th>Lambda</th><th>If-branch</th><th>Case-branch</th></tr></thead><tbody><tr><td>Total</td><td style="background-color: #CCFFCC">5 / 5 (100%)</td><td style="background-color: #CCFFCC">1 / 1 (100%)</td><td style="background-color: #CCFFCC">4 / 4 (100%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td><td>0 / 0 (0%)</td></tr></tbody></table><table class="source-table"><tr><td>1</td><td><pre>module A exposing (a)</pre></td></tr><tr><td>2</td><td><pre></pre></td></tr><tr><td>3</td><td><pre>a =</pre></td></tr><tr><td>4</td><td><pre><span><span class="no-coverage">    </span><span class="covered">a &amp;&amp; <span class="tooltip">10x</span></span><span class="covered">b &amp;&amp; <span class="tooltip">8x</span></span><span class="covered">c<span class="tooltip">5x</span></span></span></pre></td></tr></table></div>
</html>"""
                               }
                             ]
                         }
                }
              , { name = "lcov format - empty coverage"
                , input =
                     { coverageMetadata = Dict.empty
                     , coverageData = Dict.empty
                     , sources = Dict.empty
                     , moduleHashes = Dict.empty
                     , moduleNames = Dict.empty
                     , format = "lcov"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "coverage.lcov"
                               , contents = ""
                               }
                             ]
                         }
                }
              , { name = "lcov format - with coverage data"
                , input =
                     { coverageMetadata =
                         Dict.fromList
                             [ ( 1
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             , ( 2
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "b"
                                 , range = { start = { row = 2, column = 1 }, end = { row = 2, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             , ( 3
                               , { moduleName = "B"
                                 , moduleFilePath = "src/B.elm"
                                 , declarationName = "c"
                                 , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             ]
                     , coverageData = Dict.fromList [ ( 1, 1 ), ( 2, 0 ), ( 3, 1 ) ]
                     , sources =
                         Dict.fromList
                             [ ( "src/A.elm", """module A
a = 1
b = 2""" )
                             , ( "src/B.elm", "module B\nc = 3" )
                             ]
                     , moduleHashes =
                         Dict.fromList
                             [ ( "src/A.elm", FNV1a.hash """module A
a = 1
b = 2""" )
                             , ( "src/B.elm", FNV1a.hash "module B\nc = 3" )
                             ]
                     , moduleNames = Dict.fromList [ ( "src/A.elm", "A" ), ( "src/B.elm", "B" ) ]
                     , format = "lcov"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "coverage.lcov"
                               , contents = """SF:src/A.elm
DA:1,1
DA:2,0
LH:1
LF:2
end_of_record
SF:src/B.elm
DA:1,1
LH:1
LF:1
end_of_record"""
                               }
                             ]
                         }
                }
              , { name = "csv format"
                , input =
                     { coverageMetadata = Dict.empty
                     , coverageData = Dict.empty
                     , sources = Dict.empty
                     , moduleHashes = Dict.empty
                     , moduleNames = Dict.empty
                     , format = "csv"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "coverage.csv"                                 , contents = """File,Total covered,Total total,Total %,Declaration covered,Declaration total,Declaration %,Subexpression covered,Subexpression total,Subexpression %,Lambda covered,Lambda total,Lambda %,If-branch covered,If-branch total,If-branch %,Case-branch covered,Case-branch total,Case-branch %
Total,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0""" }
                             ]
                         }
                }
              , { name = "csv format - with coverage data"
                , input =
                     { coverageMetadata =
                         Dict.fromList
                             [ ( 1
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "a"
                                 , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             , ( 2
                               , { moduleName = "A"
                                 , moduleFilePath = "src/A.elm"
                                 , declarationName = "b"
                                 , range = { start = { row = 2, column = 1 }, end = { row = 2, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             , ( 3
                               , { moduleName = "B"
                                 , moduleFilePath = "src/B.elm"
                                 , declarationName = "c"
                                 , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             , ( 4
                               , { moduleName = "C"
                                 , moduleFilePath = "src/C.elm"
                                 , declarationName = "d"
                                 , range = { start = { row = 1, column = 1 }, end = { row = 1, column = 5 } }
                                 , category = "declaration"
                                 }
                               )
                             ]
                     , coverageData = Dict.fromList [ ( 1, 1 ), ( 2, 0 ), ( 3, 1 ), ( 4, 0 ) ]
                     , sources = Dict.fromList [ ( "src/A.elm", "module A" ), ( "src/B.elm", "module B" ), ( "src/C.elm", "module C" ) ]
                     , moduleHashes =
                         Dict.fromList
                             [ ( "src/A.elm", FNV1a.hash "module A" )
                             , ( "src/B.elm", FNV1a.hash "module B" )
                             , ( "src/C.elm", FNV1a.hash "module C" )
                             ]
                     , moduleNames = Dict.fromList [ ( "src/A.elm", "A" ), ( "src/B.elm", "B" ), ( "src/C.elm", "C" ) ]
                     , format = "csv"
                     }
                , output =
                     Ok
                         { reports =
                             [ { filepath = "coverage.csv"
                                 , contents = """File,Total covered,Total total,Total %,Declaration covered,Declaration total,Declaration %,Subexpression covered,Subexpression total,Subexpression %,Lambda covered,Lambda total,Lambda %,If-branch covered,If-branch total,If-branch %,Case-branch covered,Case-branch total,Case-branch %
Total,2,4,50,2,4,50,0,0,0,0,0,0,0,0,0,0,0,0
src/A.elm,1,2,50,1,2,50,0,0,0,0,0,0,0,0,0,0,0,0
src/B.elm,1,1,100,1,1,100,0,0,0,0,0,0,0,0,0,0,0,0
src/C.elm,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0"""
                               }
                             ]
                         }
                }
              , { name = "hash mismatch error"
                , input =
                     { coverageMetadata = Dict.empty
                     , coverageData = Dict.empty
                     , sources = Dict.fromList [ ( "src/A.elm", "module A" ) ]
                     , moduleHashes = Dict.fromList [ ( "src/A.elm", 999999 ) ]
                     , moduleNames = Dict.fromList [ ( "src/A.elm", "A" ) ]
                     , format = "plaintext"
                     }
                , output =
                     Err "Content hash mismatch for files: src/A.elm"
                }
              , { name = "unsupported format error"
                , input =
                     { coverageMetadata = Dict.empty
                     , coverageData = Dict.empty
                     , sources = Dict.empty
                     , moduleHashes = Dict.empty
                     , moduleNames = Dict.empty
                     , format = "unknown"
                     }
                , output =
                     Err "Unsupported format: unknown"
                }
              , { name = "missing module hash"
                , input =
                     { coverageMetadata = Dict.empty
                     , coverageData = Dict.empty
                     , sources = Dict.fromList [ ( "src/A.elm", "module A" ) ]
                     , moduleHashes = Dict.empty
                     , moduleNames = Dict.fromList [ ( "src/A.elm", "A" ) ]
                     , format = "plaintext"
                     }
                , output =
                     Err "Content hash mismatch for files: src/A.elm"
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
                -- Convert module name dots to slashes for filepath
                moduleFilePath : String
                moduleFilePath =
                    (moduleName
                        |> String.split "."
                        |> String.join "/"
                    )
                        ++ ".elm"

                ( coverageMetadataList, coverageDataList ) =
                    points
                        |> List.map
                            (\( pointId, range, count ) ->
                                ( ( pointId
                                  , { moduleName = moduleName
                                    , moduleFilePath = moduleFilePath
                                    , declarationName = "decl" ++ String.fromInt pointId
                                    , range = range
                                    , category = "declaration"
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
                    Dict.fromList [ ( moduleFilePath, FNV1a.hash source ) ]

                moduleNames =
                    Dict.fromList [ ( moduleFilePath, moduleName ) ]
            in
            { coverageMetadata = coverageMetadata
            , coverageData = coverageData
            , sources = Dict.fromList [ ( moduleFilePath, source ) ]
            , moduleHashes = moduleHashes
            , moduleNames = moduleNames
            , format = format
            }
        )
        moduleNameFuzzer
        sourceFuzzer
        (Fuzz.list pointFuzzer)
