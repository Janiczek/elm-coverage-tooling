module Report.Stdout exposing (generate)

import Report exposing (Input, ModuleStats, CategoryStats, ReportFile)


generate : Input -> { reports : List ReportFile }
generate input =
    let
        moduleStats : List ModuleStats
        moduleStats =
            Report.calculateModuleStats input

        addCategoryStats : CategoryStats -> CategoryStats -> CategoryStats
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

        formatCategoryStats : CategoryStats -> String
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

        -- ANSI color codes
        ansiReset = "\u{001B}[0m"
        ansiRedBg = "\u{001B}[101m"
        ansiYellowBg = "\u{001B}[103m"
        ansiGreenBg = "\u{001B}[102m"

        -- Get ANSI color code for a percentage (only if total > 0)
        getAnsiColor : Float -> Int -> String
        getAnsiColor percentage total =
            if total == 0 then
                ""
            else if percentage >= 100 then
                ansiGreenBg
            else if percentage == 0 then
                ansiRedBg
            else
                ansiYellowBg

        -- Format a cell with ANSI color
        formatColoredCell : Float -> Int -> String -> String
        formatColoredCell percentage total content =
            let
                colorCode = getAnsiColor percentage total
                resetCode = if colorCode == "" then "" else ansiReset
            in
            colorCode ++ content ++ resetCode

        formatRow : ModuleStats -> String
        formatRow stats =
            padLeft fileColumnWidth stats.moduleFilePath
                ++ "  "
                ++ formatColoredCell stats.coveragePercentage stats.totalPoints (padRight exprsColumnWidth (formatExprs stats.coveredPoints stats.totalPoints))
                ++ "  "
                ++ formatColoredCell stats.coveragePercentage stats.totalPoints (padRight percentageColumnWidth (formatPercentage stats.coveragePercentage))
                ++ "  "
                ++ formatColoredCell stats.declaration.percentage stats.declaration.total (padRight categoryColumnWidth (formatCategoryStats stats.declaration))
                ++ "  "
                ++ formatColoredCell stats.subexpression.percentage stats.subexpression.total (padRight categoryColumnWidth (formatCategoryStats stats.subexpression))
                ++ "  "
                ++ formatColoredCell stats.lambda.percentage stats.lambda.total (padRight categoryColumnWidth (formatCategoryStats stats.lambda))
                ++ "  "
                ++ formatColoredCell stats.ifBranch.percentage stats.ifBranch.total (padRight categoryColumnWidth (formatCategoryStats stats.ifBranch))
                ++ "  "
                ++ formatColoredCell stats.caseBranch.percentage stats.caseBranch.total (padRight categoryColumnWidth (formatCategoryStats stats.caseBranch))

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
        [ { filepath = "stdout"
          , contents =
                String.join "\n" tableRows
          }
        ]
    }
