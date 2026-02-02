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

        formatCategoryHeader : String -> String
        formatCategoryHeader name =
            name

        -- Calculate column width for hits/total part of a category
        calculateCategoryExprsWidth : String -> (ModuleStats -> Report.CategoryStats) -> Int
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
        calculateCategoryPercentageWidth : (ModuleStats -> Report.CategoryStats) -> Int
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

        formatRow : ModuleStats -> String
        formatRow stats =
            padLeft fileColumnWidth stats.moduleFilePath
                ++ "  "
                ++ padRight exprsColumnWidth (formatExprs stats.coveredPoints stats.totalPoints)
                ++ "  "
                ++ padRight percentageColumnWidth (formatPercentage stats.coveragePercentage)
                ++ "  "
                ++ padRight declarationExprsWidth (formatExprs stats.declaration.covered stats.declaration.total)
                ++ "  "
                ++ padRight declarationPercentageWidth (formatPercentage stats.declaration.percentage)
                ++ "  "
                ++ padRight subexpressionExprsWidth (formatExprs stats.subexpression.covered stats.subexpression.total)
                ++ "  "
                ++ padRight subexpressionPercentageWidth (formatPercentage stats.subexpression.percentage)
                ++ "  "
                ++ padRight lambdaExprsWidth (formatExprs stats.lambda.covered stats.lambda.total)
                ++ "  "
                ++ padRight lambdaPercentageWidth (formatPercentage stats.lambda.percentage)
                ++ "  "
                ++ padRight ifBranchExprsWidth (formatExprs stats.ifBranch.covered stats.ifBranch.total)
                ++ "  "
                ++ padRight ifBranchPercentageWidth (formatPercentage stats.ifBranch.percentage)
                ++ "  "
                ++ padRight caseBranchExprsWidth (formatExprs stats.caseBranch.covered stats.caseBranch.total)
                ++ "  "
                ++ padRight caseBranchPercentageWidth (formatPercentage stats.caseBranch.percentage)

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
        [ { filepath = "coverage.txt"
          , contents =
                String.join "\n" tableRows
          }
        ]
    }
