module Report exposing (Input, ModuleStats, CategoryStats, ReportFile, calculateModuleStats)

import Dict exposing (Dict)
import PointId exposing (PointId)
import PointMetadata exposing (PointMetadata)
import Range exposing (Range)


type alias ModuleName =
    String


type alias SourceCode =
    String


type alias ExecutionCount =
    Int


type alias ContentHash =
    Int


type alias Filepath =
    String

    

type alias Input =
    { coverageMetadata : Dict PointId PointMetadata
    , coverageData : Dict PointId ExecutionCount
    , sources : Dict Filepath SourceCode
    , moduleHashes : Dict Filepath ContentHash
    , moduleNames : Dict Filepath ModuleName
    , format : String
    }


type alias ReportFile =
    { filepath : String
    , contents : String
    }


type alias CategoryStats =
    { total : Int
    , covered : Int
    , percentage : Float
    }


type alias ModuleStats =
    { moduleFilePath : String
    , totalPoints : Int
    , coveredPoints : Int
    , coveragePercentage : Float
    , declaration : CategoryStats
    , subexpression : CategoryStats
    , lambda : CategoryStats
    , ifBranch : CategoryStats
    , caseBranch : CategoryStats
    }


calculateModuleStats : Input -> List ModuleStats
calculateModuleStats input =
    let
        pointsByFilepath : Dict Filepath (List PointId)
        pointsByFilepath =
            Dict.foldl
                (\pointId metadata acc ->
                    Dict.update metadata.moduleFilePath
                        (\maybePoints ->
                            case maybePoints of
                                Nothing ->
                                    Just [ pointId ]

                                Just points ->
                                    Just (pointId :: points)
                        )
                        acc
                )
                Dict.empty
                input.coverageMetadata

        moduleStatsList : List ModuleStats
        moduleStatsList =
            Dict.toList pointsByFilepath
                |> List.map
                    (\( filepath, pointIds ) ->
                        let
                            totalPoints : Int
                            totalPoints =
                                List.length pointIds

                            coveredPoints : Int
                            coveredPoints =
                                List.filter
                                    (\pointId ->
                                        Dict.get pointId input.coverageData
                                            |> Maybe.map (\count -> count > 0)
                                            |> Maybe.withDefault False
                                    )
                                    pointIds
                                    |> List.length

                            coveragePercentage : Float
                            coveragePercentage =
                                if totalPoints > 0 then
                                    (toFloat coveredPoints / toFloat totalPoints) * 100
                                else
                                    0

                            -- Calculate per-category stats
                            calculateCategoryStats : String -> CategoryStats
                            calculateCategoryStats category =
                                let
                                    categoryPoints : List PointId
                                    categoryPoints =
                                        List.filter
                                            (\pointId ->
                                                Dict.get pointId input.coverageMetadata
                                                    |> Maybe.map (\meta -> meta.category == category)
                                                    |> Maybe.withDefault False
                                            )
                                            pointIds

                                    categoryTotal : Int
                                    categoryTotal =
                                        List.length categoryPoints

                                    categoryCovered : Int
                                    categoryCovered =
                                        List.filter
                                            (\pointId ->
                                                Dict.get pointId input.coverageData
                                                    |> Maybe.map (\count -> count > 0)
                                                    |> Maybe.withDefault False
                                            )
                                            categoryPoints
                                            |> List.length

                                    categoryPercentage : Float
                                    categoryPercentage =
                                        if categoryTotal > 0 then
                                            (toFloat categoryCovered / toFloat categoryTotal) * 100
                                        else
                                            0
                                in
                                { total = categoryTotal
                                , covered = categoryCovered
                                , percentage = categoryPercentage
                                }
                        in
                        { moduleFilePath = filepath
                        , totalPoints = totalPoints
                        , coveredPoints = coveredPoints
                        , coveragePercentage = coveragePercentage
                        , declaration = calculateCategoryStats "declaration"
                        , subexpression = calculateCategoryStats "subexpression"
                        , lambda = calculateCategoryStats "lambda"
                        , ifBranch = calculateCategoryStats "if-branch"
                        , caseBranch = calculateCategoryStats "case-branch"
                        }
                    )
                |> List.sortBy .moduleFilePath
    in
    moduleStatsList
