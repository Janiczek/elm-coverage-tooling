module Report.Csv exposing (generate)

import Report exposing (Input, ModuleStats, ReportFile)


generate : Input -> { reports : List ReportFile }
generate input =
    let
        moduleStats : List ModuleStats
        moduleStats =
            Report.calculateModuleStats input

        totalStats : ModuleStats
        totalStats =
            List.foldl
                (\moduleStat acc ->
                    { moduleFilePath = "Total"
                    , totalPoints = acc.totalPoints + moduleStat.totalPoints
                    , coveredPoints = acc.coveredPoints + moduleStat.coveredPoints
                    , coveragePercentage =
                        if acc.totalPoints + moduleStat.totalPoints > 0 then
                            (toFloat (acc.coveredPoints + moduleStat.coveredPoints) / toFloat (acc.totalPoints + moduleStat.totalPoints)) * 100
                        else
                            0
                    }
                )
                { moduleFilePath = "Total"
                , totalPoints = 0
                , coveredPoints = 0
                , coveragePercentage = 0
                }
                moduleStats

        formatModuleRow : ModuleStats -> String
        formatModuleRow stats =
            String.join ","
                [ stats.moduleFilePath
                , String.fromInt stats.coveredPoints
                , String.fromInt stats.totalPoints
                , String.fromFloat (roundTo 2 stats.coveragePercentage)
                ]

        header : String
        header =
            "File,Exprs covered,Exprs total,Percentage"

        totalRow : String
        totalRow =
            formatModuleRow totalStats

        moduleRows : List String
        moduleRows =
            List.map formatModuleRow moduleStats

        csvContent : String
        csvContent =
            String.join "\n" (header :: totalRow :: moduleRows)
    in
    { reports =
        [ { filepath = "coverage.csv"
          , contents = csvContent
          }
        ]
    }


roundTo : Int -> Float -> Float
roundTo decimals num =
    let
        multiplier : Float
        multiplier =
            10 ^ toFloat decimals
    in
    toFloat (round (num * multiplier)) / multiplier
