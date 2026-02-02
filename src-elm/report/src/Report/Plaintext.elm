module Report.Plaintext exposing (generate)

import Report exposing (Input, ModuleStats, ReportFile)


generate : Input -> { reports : List ReportFile }
generate input =
    let
        moduleStats : List ModuleStats
        moduleStats =
            Report.calculateModuleStats input

        addCategoryStats : Report.CategoryStats -> Report.CategoryStats -> Report.CategoryStats
        addCategoryStats a b =
            let
                total = a.total + b.total
                covered = a.covered + b.covered
                percentage =
                    if total > 0 then
                        (toFloat covered / toFloat total) * 100
                    else
                        0
            in
            { total = total
            , covered = covered
            , percentage = percentage
            }

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
                    , declaration = addCategoryStats acc.declaration moduleStat.declaration
                    , subexpression = addCategoryStats acc.subexpression moduleStat.subexpression
                    , lambda = addCategoryStats acc.lambda moduleStat.lambda
                    , ifBranch = addCategoryStats acc.ifBranch moduleStat.ifBranch
                    , caseBranch = addCategoryStats acc.caseBranch moduleStat.caseBranch
                    }
                )
                { moduleFilePath = "Total"
                , totalPoints = 0
                , coveredPoints = 0
                , coveragePercentage = 0
                , declaration = { total = 0, covered = 0, percentage = 0 }
                , subexpression = { total = 0, covered = 0, percentage = 0 }
                , lambda = { total = 0, covered = 0, percentage = 0 }
                , ifBranch = { total = 0, covered = 0, percentage = 0 }
                , caseBranch = { total = 0, covered = 0, percentage = 0 }
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
                (String.length "Total")
                allStatsForWidth

        percentageColumnWidth : Int
        percentageColumnWidth =
            List.foldl
                (\stats acc ->
                    max acc (String.length (formatPercentage stats.coveragePercentage))
                )
                (String.length "%")
                allStatsForWidth

        formatCategoryStats : Report.CategoryStats -> String
        formatCategoryStats cat =
            formatExprs cat.covered cat.total ++ " " ++ formatPercentage cat.percentage

        formatCategoryHeader : String -> String
        formatCategoryHeader name =
            name ++ " (c/t/%)"

        -- Calculate column widths for category columns
        categoryColumnWidth : Int
        categoryColumnWidth =
            List.foldl
                (\stats acc ->
                    max acc
                        (max (String.length (formatCategoryStats stats.declaration))
                            (max (String.length (formatCategoryStats stats.subexpression))
                                (max (String.length (formatCategoryStats stats.lambda))
                                    (max (String.length (formatCategoryStats stats.ifBranch))
                                        (String.length (formatCategoryStats stats.caseBranch))
                                    )
                                )
                            )
                        )
                )
                (String.length (formatCategoryHeader "Declaration"))
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
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryStats stats.declaration)
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryStats stats.subexpression)
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryStats stats.lambda)
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryStats stats.ifBranch)
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryStats stats.caseBranch)

        headerRow : String
        headerRow =
            padLeft fileColumnWidth "File"
                ++ "  "
                ++ padRight exprsColumnWidth "Total"
                ++ "  "
                ++ padRight percentageColumnWidth "%"
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryHeader "Declaration")
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryHeader "Subexpression")
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryHeader "Lambda")
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryHeader "If-branch")
                ++ "  "
                ++ padRight categoryColumnWidth (formatCategoryHeader "Case-branch")

        totalRowWidth : Int
        totalRowWidth =
            fileColumnWidth + 2 + exprsColumnWidth + 2 + percentageColumnWidth + 2
                + (categoryColumnWidth + 2) * 5

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
