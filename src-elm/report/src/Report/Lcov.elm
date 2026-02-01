module Report.Lcov exposing (generate)

import Dict exposing (Dict)
import PointMetadata exposing (PointMetadata)
import Report exposing (Input, ReportFile)
import Sweep exposing (Annotation, Region)


generate : Input -> { reports : List ReportFile }
generate input =
    let
        modules : Dict String (List ( Int, PointMetadata ))
        modules =
            Dict.foldl
                (\pointId metadata acc ->
                    Dict.update metadata.moduleFilePath
                        (\maybeList ->
                            case maybeList of
                                Nothing ->
                                    Just [ ( pointId, metadata ) ]

                                Just list ->
                                    Just (( pointId, metadata ) :: list)
                        )
                        acc
                )
                Dict.empty
                input.coverageMetadata

        records : List String
        records =
            Dict.foldl
                (\filepath modulePoints acc ->
                    let
                        sourceCode : String
                        sourceCode =
                            Dict.get filepath input.sources
                                |> Maybe.withDefault ""

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

                        sourceCodeDict : Dict Int String
                        sourceCodeDict =
                            sourceCode
                                |> String.split "\n"
                                |> List.indexedMap (\index line -> ( index + 1, line ))
                                |> Dict.fromList

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
                modules
                |> List.reverse
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
