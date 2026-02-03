module Report.Lcov exposing (generate)

import Dict exposing (Dict)
import Dict.Extra
import PointMetadata exposing (PointMetadata)
import Report exposing (PreparedInput, ReportFile)
import Sweep exposing (Annotation, Region)


sourceToLinesDict : String -> Dict Int String
sourceToLinesDict sourceCode =
    sourceCode
        |> String.split "\n"
        |> List.indexedMap (\index line -> ( index + 1, line ))
        |> Dict.fromList


generate : PreparedInput -> { reports : List ReportFile }
generate input =
    let
        sourcesByLine : Dict String (Dict Int String)
        sourcesByLine =
            input.sources
                |> Dict.map (\_ src -> sourceToLinesDict src)

        records : List String
        records =
            input.modulesByFilepath
                |> Dict.foldr
                    (\filepath modulePoints acc ->
                        let
                            sourceCodeDict : Dict Int String
                            sourceCodeDict =
                                Dict.get filepath sourcesByLine
                                    |> Maybe.withDefault Dict.empty

                            regions : List Region
                            regions =
                                List.map
                                    (\( pointId, metadata ) ->
                                        let
                                            count : Int
                                            count =
                                                Dict.get pointId input.coverageData
                                                    |> Maybe.withDefault 0
                                        in
                                        { range = metadata.range
                                        , count = count
                                        }
                                    )
                                    modulePoints

                            annotations : List Annotation
                            annotations =
                                Sweep.annotate sourceCodeDict regions

                            lineCoverage : Dict Int Int
                            lineCoverage =
                                List.foldl
                                    (\annotation acc2 ->
                                        Dict.update annotation.line
                                            (\maybeCount ->
                                                case maybeCount of
                                                    Nothing ->
                                                        Just annotation.count

                                                    Just existingCount ->
                                                        Just (Basics.max existingCount annotation.count)
                                            )
                                            acc2
                                    )
                                    Dict.empty
                                    annotations

                            linesWithCoverage : Dict Int Int
                            linesWithCoverage =
                                Dict.foldl
                                    (\line count acc2 ->
                                        if count >= 0 then
                                            Dict.insert line count acc2

                                        else
                                            acc2
                                    )
                                    Dict.empty
                                    lineCoverage

                            linesFound : Int
                            linesFound =
                                Dict.size linesWithCoverage

                            linesHit : Int
                            linesHit =
                                Dict.foldl
                                    (\_ count acc2 ->
                                        if count > 0 then
                                            acc2 + 1

                                        else
                                            acc2
                                    )
                                    0
                                    linesWithCoverage

                            record : String
                            record =
                                generateRecord filepath linesFound linesHit linesWithCoverage
                        in
                        record :: acc
                    )
                    []
    in
    { reports =
        [ { filepath = "coverage.lcov"
          , contents = String.join "\n" records
          }
        ]
    }


generateRecord : String -> Int -> Int -> Dict Int Int -> String
generateRecord sourceFile linesFound linesHit lineCoverage =
    let
        daEntries : List String
        daEntries =
            lineCoverage
                |> Dict.toList
                |> List.sortBy Tuple.first
                |> List.map
                    (\( line, count ) ->
                        "DA:" ++ String.fromInt line ++ "," ++ String.fromInt count
                    )

        recordLines : List String
        recordLines =
            [ "SF:" ++ sourceFile
            ]
                ++ daEntries
                ++ [ "LH:" ++ String.fromInt linesHit
                   , "LF:" ++ String.fromInt linesFound
                   , "end_of_record"
                   ]
    in
    String.join "\n" recordLines
