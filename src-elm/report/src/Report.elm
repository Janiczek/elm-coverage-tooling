module Report exposing (CategoryStats, Input, ModuleStats, PreparedInput, ReportFile, calculateModuleStats, prepareInput)

import Dict exposing (Dict)
import Dict.Extra
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


{-| Input plus precomputed modules/points by filepath, so we do the groupBy once.
-}
type alias PreparedInput =
    { coverageMetadata : Dict PointId PointMetadata
    , coverageData : Dict PointId ExecutionCount
    , sources : Dict Filepath SourceCode
    , moduleHashes : Dict Filepath ContentHash
    , moduleNames : Dict Filepath ModuleName
    , format : String
    , modulesByFilepath : Dict Filepath (List ( PointId, PointMetadata ))
    , pointsByFilepath : Dict Filepath (List PointId)
    }


prepareInput : Input -> PreparedInput
prepareInput input =
    let
        modulesByFilepath : Dict Filepath (List ( PointId, PointMetadata ))
        modulesByFilepath =
            input.coverageMetadata
                |> Dict.toList
                |> Dict.Extra.groupBy (\( _, metadata ) -> metadata.moduleFilePath)

        pointsByFilepath : Dict Filepath (List PointId)
        pointsByFilepath =
            Dict.map (\_ pairs -> List.map Tuple.first pairs) modulesByFilepath
    in
    { coverageMetadata = input.coverageMetadata
    , coverageData = input.coverageData
    , sources = input.sources
    , moduleHashes = input.moduleHashes
    , moduleNames = input.moduleNames
    , format = input.format
    , modulesByFilepath = modulesByFilepath
    , pointsByFilepath = pointsByFilepath
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


calculateModuleStats : PreparedInput -> List ModuleStats
calculateModuleStats input =
    let
        moduleStatsList : List ModuleStats
        moduleStatsList =
            input.pointsByFilepath
                |> Dict.toList
                |> List.map
                    (\( filepath, pointIds ) ->
                        let
                            acc0 :
                                { total : Int
                                , covered : Int
                                , declarationTotal : Int
                                , declarationCovered : Int
                                , subexpressionTotal : Int
                                , subexpressionCovered : Int
                                , lambdaTotal : Int
                                , lambdaCovered : Int
                                , ifBranchTotal : Int
                                , ifBranchCovered : Int
                                , caseBranchTotal : Int
                                , caseBranchCovered : Int
                                }
                            acc0 =
                                { total = 0
                                , covered = 0
                                , declarationTotal = 0
                                , declarationCovered = 0
                                , subexpressionTotal = 0
                                , subexpressionCovered = 0
                                , lambdaTotal = 0
                                , lambdaCovered = 0
                                , ifBranchTotal = 0
                                , ifBranchCovered = 0
                                , caseBranchTotal = 0
                                , caseBranchCovered = 0
                                }

                            boolToInt : Bool -> Int
                            boolToInt bool =
                                if bool then
                                    1

                                else
                                    0

                            acc : { total : Int, covered : Int, declarationTotal : Int, declarationCovered : Int, subexpressionTotal : Int, subexpressionCovered : Int, lambdaTotal : Int, lambdaCovered : Int, ifBranchTotal : Int, ifBranchCovered : Int, caseBranchTotal : Int, caseBranchCovered : Int }
                            acc =
                                List.foldl
                                    (\pointId a ->
                                        let
                                            meta : Maybe PointMetadata
                                            meta =
                                                Dict.get pointId input.coverageMetadata

                                            isCovered : Bool
                                            isCovered =
                                                Dict.get pointId input.coverageData
                                                    |> Maybe.map (\count -> count > 0)
                                                    |> Maybe.withDefault False

                                            category : String
                                            category =
                                                Maybe.map .category meta
                                                    |> Maybe.withDefault ""
                                        in
                                        { total = a.total + 1
                                        , covered = a.covered + boolToInt isCovered
                                        , declarationTotal = a.declarationTotal + boolToInt (category == "declaration")
                                        , declarationCovered = a.declarationCovered + boolToInt (category == "declaration" && isCovered)
                                        , subexpressionTotal = a.subexpressionTotal + boolToInt (category == "subexpression")
                                        , subexpressionCovered = a.subexpressionCovered + boolToInt (category == "subexpression" && isCovered)
                                        , lambdaTotal = a.lambdaTotal + boolToInt (category == "lambda")
                                        , lambdaCovered = a.lambdaCovered + boolToInt (category == "lambda" && isCovered)
                                        , ifBranchTotal = a.ifBranchTotal + boolToInt (category == "if-branch")
                                        , ifBranchCovered = a.ifBranchCovered + boolToInt (category == "if-branch" && isCovered)
                                        , caseBranchTotal = a.caseBranchTotal + boolToInt (category == "case-branch")
                                        , caseBranchCovered = a.caseBranchCovered + boolToInt (category == "case-branch" && isCovered)
                                        }
                                    )
                                    acc0
                                    pointIds

                            totalPoints : Int
                            totalPoints =
                                acc.total

                            coveredPoints : Int
                            coveredPoints =
                                acc.covered

                            coveragePercentage : Float
                            coveragePercentage =
                                if totalPoints > 0 then
                                    (toFloat coveredPoints / toFloat totalPoints) * 100

                                else
                                    0

                            toCategoryStats : Int -> Int -> CategoryStats
                            toCategoryStats total covered =
                                { total = total
                                , covered = covered
                                , percentage =
                                    if total > 0 then
                                        (toFloat covered / toFloat total) * 100

                                    else
                                        0
                                }
                        in
                        { moduleFilePath = filepath
                        , totalPoints = totalPoints
                        , coveredPoints = coveredPoints
                        , coveragePercentage = coveragePercentage
                        , declaration = toCategoryStats acc.declarationTotal acc.declarationCovered
                        , subexpression = toCategoryStats acc.subexpressionTotal acc.subexpressionCovered
                        , lambda = toCategoryStats acc.lambdaTotal acc.lambdaCovered
                        , ifBranch = toCategoryStats acc.ifBranchTotal acc.ifBranchCovered
                        , caseBranch = toCategoryStats acc.caseBranchTotal acc.caseBranchCovered
                        }
                    )
                |> List.sortBy .moduleFilePath
    in
    moduleStatsList
