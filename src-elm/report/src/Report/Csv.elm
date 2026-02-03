module Report.Csv exposing (generate)

import Report exposing (CategoryStats, ModuleStats, PreparedInput, ReportFile)


generate : PreparedInput -> { reports : List ReportFile }
generate input =
    let
        moduleStats : List ModuleStats
        moduleStats =
            Report.calculateModuleStats input

        addCategoryStats : Report.CategoryStats -> Report.CategoryStats -> Report.CategoryStats
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

        formatCategoryStats : Report.CategoryStats -> String
        formatCategoryStats cat =
            String.fromInt cat.covered
                ++ ","
                ++ String.fromInt cat.total
                ++ ","
                ++ String.fromFloat (roundTo 2 cat.percentage)

        formatModuleRow : ModuleStats -> String
        formatModuleRow stats =
            String.join ","
                ([ stats.moduleFilePath
                 , String.fromInt stats.coveredPoints
                 , String.fromInt stats.totalPoints
                 , String.fromFloat (roundTo 2 stats.coveragePercentage)
                 ]
                    ++ [ formatCategoryStats stats.declaration
                       , formatCategoryStats stats.subexpression
                       , formatCategoryStats stats.lambda
                       , formatCategoryStats stats.ifBranch
                       , formatCategoryStats stats.caseBranch
                       ]
                )

        header : String
        header =
            "File,Total covered,Total total,Total %,Declaration covered,Declaration total,Declaration %,Subexpression covered,Subexpression total,Subexpression %,Lambda covered,Lambda total,Lambda %,If-branch covered,If-branch total,If-branch %,Case-branch covered,Case-branch total,Case-branch %"

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
