module Report exposing (Input, ModuleStats, ReportFile, calculateModuleStats)

import Dict exposing (Dict)
import List
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


type alias ModuleStats =
    { moduleFilePath : String
    , totalPoints : Int
    , coveredPoints : Int
    , coveragePercentage : Float
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
                        in
                        { moduleFilePath = filepath
                        , totalPoints = totalPoints
                        , coveredPoints = coveredPoints
                        , coveragePercentage = coveragePercentage
                        }
                    )
                |> List.sortBy .moduleFilePath
    in
    moduleStatsList
