module Report.Plaintext exposing (generate)

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

        allStatsForWidth : List ModuleStats
        allStatsForWidth =
            totalStats :: moduleStats

        formatExprs : Int -> Int -> String
        formatExprs covered total =
            String.fromInt covered ++ "/" ++ String.fromInt total

        formatPercentage : Float -> String
        formatPercentage percentage =
            String.fromInt (round percentage) ++ "%"

        fileColumnWidth : Int
        fileColumnWidth =
            List.foldl
                (\stats acc ->
                    max acc (String.length stats.moduleFilePath)
                )
                (String.length "File")
                allStatsForWidth

        exprsColumnWidth : Int
        exprsColumnWidth =
            List.foldl
                (\stats acc ->
                    max acc (String.length (formatExprs stats.coveredPoints stats.totalPoints))
                )
                (String.length "Exprs")
                allStatsForWidth

        percentageColumnWidth : Int
        percentageColumnWidth =
            List.foldl
                (\stats acc ->
                    max acc (String.length (formatPercentage stats.coveragePercentage))
                )
                (String.length "%")
                allStatsForWidth

        padLeft : Int -> String -> String
        padLeft width str =
            str ++ String.repeat (width - String.length str) " "

        padRight : Int -> String -> String
        padRight width str =
            String.repeat (width - String.length str) " " ++ str

        formatRow : ModuleStats -> String
        formatRow stats =
            padLeft fileColumnWidth stats.moduleFilePath
                ++ "  "
                ++ padRight exprsColumnWidth (formatExprs stats.coveredPoints stats.totalPoints)
                ++ "  "
                ++ padRight percentageColumnWidth (formatPercentage stats.coveragePercentage)

        headerRow : String
        headerRow =
            padLeft fileColumnWidth "File"
                ++ "  "
                ++ padRight exprsColumnWidth "Exprs"
                ++ "  "
                ++ padRight percentageColumnWidth "%"

        totalRowWidth : Int
        totalRowWidth =
            fileColumnWidth + 2 + exprsColumnWidth + 2 + percentageColumnWidth

        separatorRow : String
        separatorRow =
            String.repeat totalRowWidth "-"

        tableRows : List String
        tableRows =
            headerRow
                :: separatorRow
                :: List.map formatRow moduleStats
                ++ [ separatorRow
                   , formatRow totalStats
                   ]
    in
    { reports =
        [ { filepath = "coverage.txt"
          , contents =
                String.join "\n" tableRows
          }
        ]
    }
