module Report exposing (Input, ModuleStats, ReportFile, calculateModuleStats)

import Dict exposing (Dict)
import List
import PointMetadata exposing (PointMetadata)
import Range exposing (Range)


type alias Input =
    { coverageMetadata : Dict Int PointMetadata
    , coverageData : Dict Int Int
    , sources : Dict String String
    , moduleHashes : Dict String Int
    , format : String
    }


type alias ReportFile =
    { filepath : String
    , contents : String
    }


type alias ModuleStats =
    { moduleName : String
    , totalPoints : Int
    , coveredPoints : Int
    , coveragePercentage : Float
    }


calculateModuleStats : Input -> List ModuleStats
calculateModuleStats input =
    let
        pointsByModule : Dict String (List Int)
        pointsByModule =
            Dict.foldl
                (\pointId metadata acc ->
                    Dict.update metadata.moduleName
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
            Dict.toList pointsByModule
                |> List.map
                    (\( modName, pointIds ) ->
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
                        { moduleName = modName
                        , totalPoints = totalPoints
                        , coveredPoints = coveredPoints
                        , coveragePercentage = coveragePercentage
                        }
                    )
                |> List.sortBy .moduleName
    in
    moduleStatsList
