module Report.Stdout exposing (generate)

import Report exposing (CategoryStats, Input, ModuleStats, ReportFile)


generate : Input -> { reports : List ReportFile }
generate input =
    let
        moduleStats : List ModuleStats
        moduleStats =
            Report.calculateModuleStats input

        addCategoryStats : CategoryStats -> CategoryStats -> CategoryStats
        addCategoryStats a b =
            let
                total =
                    a.total + b.total

                covered =
                    a.covered + b.covered

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

        formatCategoryHeader : String -> String
        formatCategoryHeader name =
            name

        -- Calculate column width for hits/total part of a category
        calculateCategoryExprsWidth : String -> (ModuleStats -> CategoryStats) -> Int
        calculateCategoryExprsWidth headerName getCategory =
            let
                headerWidth = String.length (formatCategoryHeader headerName)
            in
            List.foldl
                (\stats acc ->
                    let
                        cat = getCategory stats
                    in
                    max acc (String.length (formatExprs cat.covered cat.total))
                )
                headerWidth
                allStatsForWidth

        -- Calculate column width for percentage part of a category
        calculateCategoryPercentageWidth : (ModuleStats -> CategoryStats) -> Int
        calculateCategoryPercentageWidth getCategory =
            List.foldl
                (\stats acc ->
                    let
                        cat = getCategory stats
                    in
                    max acc (String.length (formatPercentage cat.percentage))
                )
                (String.length "%")
                allStatsForWidth

        declarationExprsWidth : Int
        declarationExprsWidth =
            calculateCategoryExprsWidth "Declaration" .declaration

        declarationPercentageWidth : Int
        declarationPercentageWidth =
            calculateCategoryPercentageWidth .declaration

        subexpressionExprsWidth : Int
        subexpressionExprsWidth =
            calculateCategoryExprsWidth "Subexpression" .subexpression

        subexpressionPercentageWidth : Int
        subexpressionPercentageWidth =
            calculateCategoryPercentageWidth .subexpression

        lambdaExprsWidth : Int
        lambdaExprsWidth =
            calculateCategoryExprsWidth "Lambda" .lambda

        lambdaPercentageWidth : Int
        lambdaPercentageWidth =
            calculateCategoryPercentageWidth .lambda

        ifBranchExprsWidth : Int
        ifBranchExprsWidth =
            calculateCategoryExprsWidth "If-branch" .ifBranch

        ifBranchPercentageWidth : Int
        ifBranchPercentageWidth =
            calculateCategoryPercentageWidth .ifBranch

        caseBranchExprsWidth : Int
        caseBranchExprsWidth =
            calculateCategoryExprsWidth "Case-branch" .caseBranch

        caseBranchPercentageWidth : Int
        caseBranchPercentageWidth =
            calculateCategoryPercentageWidth .caseBranch

        padLeft : Int -> String -> String
        padLeft width str =
            str ++ String.repeat (width - String.length str) " "

        padRight : Int -> String -> String
        padRight width str =
            String.repeat (width - String.length str) " " ++ str

        -- ANSI color codes (foreground only)
        ansiReset =
            "\u{001B}[0m"

        ansiRed =
            "\u{001B}[31m"

        ansiBrRed =
            "\u{001B}[91m"

        ansiGreen =
            "\u{001B}[32m"

        -- Get ANSI color code for a percentage (only if total > 0)
        getAnsiColor : Float -> Int -> String
        getAnsiColor percentage total =
            if total == 0 then
                ""

            else if percentage >= 100 then
                ansiGreen

            else if percentage == 0 then
                ansiRed

            else
                ansiBrRed

        -- Format a cell with ANSI color
        formatColoredCell : Float -> Int -> String -> String
        formatColoredCell percentage total content =
            let
                colorCode =
                    getAnsiColor percentage total

                resetCode =
                    if colorCode == "" then
                        ""

                    else
                        ansiReset
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
                ++ formatColoredCell stats.declaration.percentage stats.declaration.total (padRight declarationExprsWidth (formatExprs stats.declaration.covered stats.declaration.total))
                ++ "  "
                ++ formatColoredCell stats.declaration.percentage stats.declaration.total (padRight declarationPercentageWidth (formatPercentage stats.declaration.percentage))
                ++ "  "
                ++ formatColoredCell stats.subexpression.percentage stats.subexpression.total (padRight subexpressionExprsWidth (formatExprs stats.subexpression.covered stats.subexpression.total))
                ++ "  "
                ++ formatColoredCell stats.subexpression.percentage stats.subexpression.total (padRight subexpressionPercentageWidth (formatPercentage stats.subexpression.percentage))
                ++ "  "
                ++ formatColoredCell stats.lambda.percentage stats.lambda.total (padRight lambdaExprsWidth (formatExprs stats.lambda.covered stats.lambda.total))
                ++ "  "
                ++ formatColoredCell stats.lambda.percentage stats.lambda.total (padRight lambdaPercentageWidth (formatPercentage stats.lambda.percentage))
                ++ "  "
                ++ formatColoredCell stats.ifBranch.percentage stats.ifBranch.total (padRight ifBranchExprsWidth (formatExprs stats.ifBranch.covered stats.ifBranch.total))
                ++ "  "
                ++ formatColoredCell stats.ifBranch.percentage stats.ifBranch.total (padRight ifBranchPercentageWidth (formatPercentage stats.ifBranch.percentage))
                ++ "  "
                ++ formatColoredCell stats.caseBranch.percentage stats.caseBranch.total (padRight caseBranchExprsWidth (formatExprs stats.caseBranch.covered stats.caseBranch.total))
                ++ "  "
                ++ formatColoredCell stats.caseBranch.percentage stats.caseBranch.total (padRight caseBranchPercentageWidth (formatPercentage stats.caseBranch.percentage))

        headerRow : String
        headerRow =
            padLeft fileColumnWidth "File"
                ++ "  "
                ++ padRight exprsColumnWidth "Total"
                ++ "  "
                ++ padRight percentageColumnWidth "%"
                ++ "  "
                ++ padRight declarationExprsWidth (formatCategoryHeader "Declaration")
                ++ "  "
                ++ padRight declarationPercentageWidth "%"
                ++ "  "
                ++ padRight subexpressionExprsWidth (formatCategoryHeader "Subexpression")
                ++ "  "
                ++ padRight subexpressionPercentageWidth "%"
                ++ "  "
                ++ padRight lambdaExprsWidth (formatCategoryHeader "Lambda")
                ++ "  "
                ++ padRight lambdaPercentageWidth "%"
                ++ "  "
                ++ padRight ifBranchExprsWidth (formatCategoryHeader "If-branch")
                ++ "  "
                ++ padRight ifBranchPercentageWidth "%"
                ++ "  "
                ++ padRight caseBranchExprsWidth (formatCategoryHeader "Case-branch")
                ++ "  "
                ++ padRight caseBranchPercentageWidth "%"

        totalRowWidth : Int
        totalRowWidth =
            [ fileColumnWidth
            , exprsColumnWidth
            , percentageColumnWidth
            , declarationExprsWidth
            , declarationPercentageWidth
            , subexpressionExprsWidth
            , subexpressionPercentageWidth
            , lambdaExprsWidth
            , lambdaPercentageWidth
            , ifBranchExprsWidth
            , ifBranchPercentageWidth
            , caseBranchExprsWidth
            , caseBranchPercentageWidth
            ]
                |> List.intersperse 2
                |> List.sum

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
