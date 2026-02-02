module Report.Html exposing (generate)

import Dict exposing (Dict)
import Html.String as Html
import Html.String.Attributes as Attr
import PointMetadata exposing (PointMetadata)
import Report exposing (Input, ModuleStats, CategoryStats, ReportFile)
import Sweep exposing (Annotation, Region)


generate : Input -> { reports : List ReportFile }
generate input =
    let
        modules : Dict String (List ( Int, PointMetadata ))
        modules =
            Dict.foldl
                (\pointId metadata acc ->
                    Dict.update metadata.moduleFilePath
                        (\maybeList ->
                            case maybeList of
                                Nothing ->
                                    Just [ ( pointId, metadata ) ]

                                Just list ->
                                    Just (( pointId, metadata ) :: list)
                        )
                        acc
                )
                Dict.empty
                input.coverageMetadata

        moduleStats : List ModuleStats
        moduleStats =
            Report.calculateModuleStats input

        moduleStatsDict : Dict String ModuleStats
        moduleStatsDict =
            List.foldl
                (\stat acc ->
                    Dict.insert stat.moduleFilePath stat acc
                )
                Dict.empty
                moduleStats

        totalStats : ModuleStats
        totalStats =
            calculateTotalStats moduleStats

        indexPage : ReportFile
        indexPage =
            { filepath = "index.html"
            , contents = generateIndexPage moduleStats totalStats
            }

        modulePages : List ReportFile
        modulePages =
                input.sources
                |>
            Dict.foldl
                (\filepath sourceCode acc ->
                    let
                        modulePoints : List ( Int, PointMetadata )
                        modulePoints =
                            Dict.get filepath modules
                                |> Maybe.withDefault []

                        regions : List Region
                        regions =
                            List.map
                                (\( pointId, metadata ) ->
                                    let
                                        count : Int
                                        count =
                                            Dict.get pointId input.coverageData
                                                |> Maybe.withDefault 0
                                    in
                                    { range = metadata.range
                                    , count = count
                                    }
                                )
                                modulePoints

                        sanitizedFilePath : String
                        sanitizedFilePath =
                            sanitizeFilePathForHtml filepath

                        moduleStat : Maybe ModuleStats
                        moduleStat =
                            Dict.get filepath moduleStatsDict

                        page : ReportFile
                        page =
                            { filepath = sanitizedFilePath ++ ".html"
                            , contents = generateModulePage filepath sourceCode regions moduleStat
                            }
                    in
                    page :: acc
                )
                []
    in
    { reports = indexPage :: modulePages }


sanitizeFilePathForHtml : String -> String
sanitizeFilePathForHtml filepath =
    filepath
        |> String.replace ".elm" ""


calculateTotalStats : List ModuleStats -> ModuleStats
calculateTotalStats stats =
    let
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
    in
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
        stats


interpolateCoverageColor : Float -> String
interpolateCoverageColor percentage =
    let
        -- Color endpoints: red (0%), yellow (50%), green (100%)
        redR = 255
        redG = 204
        redB = 204

        yellowR = 255
        yellowG = 255
        yellowB = 204

        greenR = 124
        greenG = 252
        greenB = 0

        lerp : Float -> Int -> Int -> Int
        lerp t start end =
            round (toFloat start + t * (toFloat end - toFloat start))

        ( r, g, b ) =
            if percentage <= 50 then
                -- Interpolate between red and yellow
                let
                    t = percentage / 50
                in
                ( lerp t redR yellowR
                , lerp t redG yellowG
                , lerp t redB yellowB
                )
            else
                -- Interpolate between yellow and green
                let
                    t = (percentage - 50) / 50
                in
                ( lerp t yellowR greenR
                , lerp t yellowG greenG
                , lerp t yellowB greenB
                )

        toHex : Int -> String
        toHex n =
            let
                high = n // 16
                low = remainderBy 16 n
            in
            toHexDigit high ++ toHexDigit low
    in
    "#" ++ toHex r ++ toHex g ++ toHex b


toHexDigit : Int -> String
toHexDigit n =
    if n < 10 then
        String.fromInt n
    else
        case n of
            10 -> "A"
            11 -> "B"
            12 -> "C"
            13 -> "D"
            14 -> "E"
            15 -> "F"
            _ -> "0"


relativePathToIndex : String -> String
relativePathToIndex sanitizedFilePath =
    let
        directoryLevels : Int
        directoryLevels =
            sanitizedFilePath
                |> String.split "/"
                |> List.length
                |> (\count -> count - 1)
    in
    if directoryLevels == 0 then
        "index.html"

    else
        String.repeat directoryLevels "../"
            ++ "index.html"


getCoverageColorWithColorMix : Float -> String
getCoverageColorWithColorMix percentage =
    if percentage <= 50 then
        -- Interpolate between red (#ffcccc) and yellow (#ffffcc)
        -- percentage goes from 0 to 50, so we need to map it to 0-100% for color-mix
        let
            mixPercentage : Float
            mixPercentage =
                (percentage / 50) * 100

            mixPercentageStr : String
            mixPercentageStr =
                String.fromFloat (roundTo 2 mixPercentage)
        in
        "color-mix(in srgb, #ffcccc " ++ mixPercentageStr ++ "%, #ffffcc)"
    else
        -- Interpolate between yellow (#ffffcc) and green (#ccffcc)
        -- percentage goes from 50 to 100, so we map it to 0-100% for color-mix
        let
            mixPercentage : Float
            mixPercentage =
                ((percentage - 50) / 50) * 100

            mixPercentageStr : String
            mixPercentageStr =
                String.fromFloat (roundTo 2 mixPercentage)
        in
        "color-mix(in srgb, #ffffcc " ++ mixPercentageStr ++ "%, #ccffcc)"


generateIndexPage : List ModuleStats -> ModuleStats -> String
generateIndexPage stats totalStats =
    let
        makeCell : Float -> Int -> String -> Html.Html msg
        makeCell percentage total content =
            let
                attrs =
                    if total > 0 then
                        [ Attr.style "background-color" (getCoverageColorWithColorMix percentage) ]
                    else
                        []
            in
            Html.td attrs
                [ Html.text content ]

        makeModuleRow : ModuleStats -> Html.Html msg
        makeModuleRow stat =
            let
                sanitizedFilePath : String
                sanitizedFilePath =
                    sanitizeFilePathForHtml stat.moduleFilePath
            in
            Html.tr []
                ([ Html.td []
                    [ Html.a [ Attr.href (sanitizedFilePath ++ ".html") ]
                        [ Html.text stat.moduleFilePath ]
                    ]
                 , makeCell stat.coveragePercentage stat.totalPoints
                    (String.fromInt stat.coveredPoints
                        ++ " / "
                        ++ String.fromInt stat.totalPoints
                        ++ " ("
                        ++ String.fromFloat (roundTo 2 stat.coveragePercentage)
                        ++ "%)"
                    )
                 ]
                    ++ [ makeCell stat.declaration.percentage stat.declaration.total
                            (String.fromInt stat.declaration.covered
                                ++ " / "
                                ++ String.fromInt stat.declaration.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.declaration.percentage)
                                ++ "%)"
                            )
                       , makeCell stat.subexpression.percentage stat.subexpression.total
                            (String.fromInt stat.subexpression.covered
                                ++ " / "
                                ++ String.fromInt stat.subexpression.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.subexpression.percentage)
                                ++ "%)"
                            )
                       , makeCell stat.lambda.percentage stat.lambda.total
                            (String.fromInt stat.lambda.covered
                                ++ " / "
                                ++ String.fromInt stat.lambda.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.lambda.percentage)
                                ++ "%)"
                            )
                       , makeCell stat.ifBranch.percentage stat.ifBranch.total
                            (String.fromInt stat.ifBranch.covered
                                ++ " / "
                                ++ String.fromInt stat.ifBranch.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.ifBranch.percentage)
                                ++ "%)"
                            )
                       , makeCell stat.caseBranch.percentage stat.caseBranch.total
                            (String.fromInt stat.caseBranch.covered
                                ++ " / "
                                ++ String.fromInt stat.caseBranch.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.caseBranch.percentage)
                                ++ "%)"
                            )
                       ]
            )

        makeTotalRow : ModuleStats -> Html.Html msg
        makeTotalRow stat =
            Html.tr []
                ([ Html.td [ Attr.style "font-weight" "bold" ]
                    [ Html.text stat.moduleFilePath ]
                 , makeCell stat.coveragePercentage stat.totalPoints
                    (String.fromInt stat.coveredPoints
                        ++ " / "
                        ++ String.fromInt stat.totalPoints
                        ++ " ("
                        ++ String.fromFloat (roundTo 2 stat.coveragePercentage)
                        ++ "%)"
                    )
                 ]
                    ++ [ makeCell stat.declaration.percentage stat.declaration.total
                            (String.fromInt stat.declaration.covered
                                ++ " / "
                                ++ String.fromInt stat.declaration.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.declaration.percentage)
                                ++ "%)"
                            )
                       , makeCell stat.subexpression.percentage stat.subexpression.total
                            (String.fromInt stat.subexpression.covered
                                ++ " / "
                                ++ String.fromInt stat.subexpression.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.subexpression.percentage)
                                ++ "%)"
                            )
                       , makeCell stat.lambda.percentage stat.lambda.total
                            (String.fromInt stat.lambda.covered
                                ++ " / "
                                ++ String.fromInt stat.lambda.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.lambda.percentage)
                                ++ "%)"
                            )
                       , makeCell stat.ifBranch.percentage stat.ifBranch.total
                            (String.fromInt stat.ifBranch.covered
                                ++ " / "
                                ++ String.fromInt stat.ifBranch.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.ifBranch.percentage)
                                ++ "%)"
                            )
                       , makeCell stat.caseBranch.percentage stat.caseBranch.total
                            (String.fromInt stat.caseBranch.covered
                                ++ " / "
                                ++ String.fromInt stat.caseBranch.total
                                ++ " ("
                                ++ String.fromFloat (roundTo 2 stat.caseBranch.percentage)
                                ++ "%)"
                            )
                       ]
            )

        rows : List (Html.Html msg)
        rows =
            List.map makeModuleRow stats
                ++ [ makeTotalRow totalStats ]

        bodyHtml : Html.Html msg
        bodyHtml =
            Html.div []
                [ Html.h1 [] [ Html.text "Coverage Report" ]
                , Html.table []
                    [ Html.thead []
                        [ Html.tr []
                            ([ Html.th [] [ Html.text "Module" ]
                             , Html.th [] [ Html.text "Total" ]
                             ]
                                ++ [ Html.th [] [ Html.text "Declaration" ]
                                   , Html.th [] [ Html.text "Subexpression" ]
                                   , Html.th [] [ Html.text "Lambda" ]
                                   , Html.th [] [ Html.text "If-branch" ]
                                   , Html.th [] [ Html.text "Case-branch" ]
                                   ]
                            )
                        ]
                    , Html.tbody [] rows
                    ]
                ]

        bodyString : String
        bodyString =
            Html.toString 0 bodyHtml
    in
    """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
"""
        ++ bodyString
        ++ """
</html>"""


calculateMinMaxCounts : List Region -> ( Maybe Int, Int )
calculateMinMaxCounts regions =
    let
        nonZeroCounts : List Int
        nonZeroCounts =
            regions
                |> List.map .count
                |> List.filter (\count -> count > 0)

        allCounts : List Int
        allCounts =
            List.map .count regions

        minNonZero : Maybe Int
        minNonZero =
            if List.isEmpty nonZeroCounts then
                Nothing
            else
                Just (List.minimum nonZeroCounts |> Maybe.withDefault 0)

        maxCount : Int
        maxCount =
            List.maximum allCounts |> Maybe.withDefault 0
    in
    ( minNonZero, maxCount )


generateModulePage : String -> String -> List Region -> Maybe ModuleStats -> String
generateModulePage moduleFilePath sourceCode regions maybeStats =
    let
        sanitizedFilePath : String
        sanitizedFilePath =
            sanitizeFilePathForHtml moduleFilePath

        indexLinkPath : String
        indexLinkPath =
            relativePathToIndex sanitizedFilePath

        ( minCount, maxCount ) =
            calculateMinMaxCounts regions

        lines : List String
        lines =
            String.split "\n" sourceCode

        sourceCodeDict : Dict Int String
        sourceCodeDict =
            lines
                |> List.indexedMap (\index line -> ( index + 1, line ))
                |> Dict.fromList

        annotations : List Annotation
        annotations =
            Sweep.annotate sourceCodeDict regions

        -- Group annotations by line
        annotationsByLine : Dict Int (List Annotation)
        annotationsByLine =
            List.foldl
                (\annotation acc ->
                    Dict.update annotation.line
                        (\maybeList ->
                            case maybeList of
                                Nothing ->
                                    Just [ annotation ]

                                Just list ->
                                    Just (annotation :: list)
                        )
                        acc
                )
                Dict.empty
                annotations

        -- Render each line with annotations
        renderedLines : List (Html.Html msg)
        renderedLines =
            List.indexedMap
                (\lineNum lineText ->
                    let
                        lineIndex : Int
                        lineIndex =
                            lineNum + 1

                        lineAnnotations : List Annotation
                        lineAnnotations =
                            Dict.get lineIndex annotationsByLine
                                |> Maybe.withDefault []

                        renderedLine : Html.Html msg
                        renderedLine =
                            if List.isEmpty lineAnnotations then
                                Html.text lineText

                            else
                                renderAnnotatedLine lineIndex lineText lineAnnotations minCount maxCount
                    in
                    Html.tr []
                        [ Html.td [] [ Html.text (String.fromInt lineIndex) ]
                        , Html.td [] [ Html.pre [ ] [ renderedLine ] ]
                        ]
                )
                lines

        summaryTable : Html.Html msg
        summaryTable =
            case maybeStats of
                Just stats ->
                    let
                        makeCell : Float -> Int -> String -> Html.Html msg
                        makeCell percentage total content =
                            let
                                attrs =
                                    if total > 0 then
                                        [ Attr.style "background-color" (getCoverageColorWithColorMix percentage) ]
                                    else
                                        []
                            in
                            Html.td attrs
                                [ Html.text content ]

                        summaryRows : List (Html.Html msg)
                        summaryRows =
                            [ Html.tr []
                                [ Html.td [] []
                                , makeCell stats.coveragePercentage stats.totalPoints
                                    (String.fromInt stats.coveredPoints
                                        ++ " / "
                                        ++ String.fromInt stats.totalPoints
                                        ++ " ("
                                        ++ String.fromFloat (roundTo 2 stats.coveragePercentage)
                                        ++ "%)"
                                    )
                                , makeCell stats.declaration.percentage stats.declaration.total
                                    (String.fromInt stats.declaration.covered
                                        ++ " / "
                                        ++ String.fromInt stats.declaration.total
                                        ++ " ("
                                        ++ String.fromFloat (roundTo 2 stats.declaration.percentage)
                                        ++ "%)"
                                    )
                                , makeCell stats.subexpression.percentage stats.subexpression.total
                                    (String.fromInt stats.subexpression.covered
                                        ++ " / "
                                        ++ String.fromInt stats.subexpression.total
                                        ++ " ("
                                        ++ String.fromFloat (roundTo 2 stats.subexpression.percentage)
                                        ++ "%)"
                                    )
                                , makeCell stats.lambda.percentage stats.lambda.total
                                    (String.fromInt stats.lambda.covered
                                        ++ " / "
                                        ++ String.fromInt stats.lambda.total
                                        ++ " ("
                                        ++ String.fromFloat (roundTo 2 stats.lambda.percentage)
                                        ++ "%)"
                                    )
                                , makeCell stats.ifBranch.percentage stats.ifBranch.total
                                    (String.fromInt stats.ifBranch.covered
                                        ++ " / "
                                        ++ String.fromInt stats.ifBranch.total
                                        ++ " ("
                                        ++ String.fromFloat (roundTo 2 stats.ifBranch.percentage)
                                        ++ "%)"
                                    )
                                , makeCell stats.caseBranch.percentage stats.caseBranch.total
                                    (String.fromInt stats.caseBranch.covered
                                        ++ " / "
                                        ++ String.fromInt stats.caseBranch.total
                                        ++ " ("
                                        ++ String.fromFloat (roundTo 2 stats.caseBranch.percentage)
                                        ++ "%)"
                                    )
                                ]
                            ]
                    in
                    Html.table [ Attr.class "summary-table" ]
                        [ Html.thead []
                            [ Html.tr []
                                ([ Html.th [] [ Html.text "Category" ]
                                 , Html.th [] [ Html.text "Total" ]
                                 ]
                                    ++ [ Html.th [] [ Html.text "Declaration" ]
                                       , Html.th [] [ Html.text "Subexpression" ]
                                       , Html.th [] [ Html.text "Lambda" ]
                                       , Html.th [] [ Html.text "If-branch" ]
                                       , Html.th [] [ Html.text "Case-branch" ]
                                       ]
                                )
                            ]
                        , Html.tbody [] summaryRows
                        ]

                Nothing ->
                    Html.text ""

        bodyHtml : Html.Html msg
        bodyHtml =
            Html.div []
                [ Html.h1 [] [ Html.text moduleFilePath ]
                , Html.p []
                    [ Html.a [ Attr.href indexLinkPath ]
                        [ Html.text "← Back to index" ]
                    ]
                , summaryTable
                , Html.table [ Attr.class "source-table" ] renderedLines
                ]

        bodyString : String
        bodyString =
            Html.toString 0 bodyHtml
    in
    """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>"""
        ++ moduleFilePath
        ++ """ - Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        table.summary-table { margin-bottom: 20px; }
        table.summary-table th, table.summary-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        table.summary-table th { background-color: #f2f2f2; }
        table.source-table td { border: none; padding: 0; line-height: 1.15; }
        table.source-table tr td:first-child { width: 1%; white-space: nowrap; padding-right: 8px; }
        .line-number { text-align: right; color: #666; user-select: none; }
        .covered { 
            background-color: #d4edda; 
            border-radius: 6px; 
            position: relative;
        }
        .covered:hover { background-color: rgba(212, 237, 218, 0.25); outline: 2px solid #d4edda; }
        .uncovered { 
            background-color: #f8d7da; 
            border-radius: 6px; 
            position: relative;
        }
        .uncovered:hover { background-color: rgba(248, 215, 218, 0.25); outline: 2px solid #f8d7da; }
        .no-coverage { background-color: transparent; }
        td:first-child {
            font-family: "JetBrains Mono", monospace; 
            text-align: right;
            color: #666;
            user-select: none;
            font-size: inherit;
        }
        pre { 
            margin: 0; 
            font-family: "JetBrains Mono", monospace; 
            white-space: pre-wrap;
            position: relative; 
        }
        .tooltip { 
            display: none;
            background-color: #333;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            white-space: nowrap;
            z-index: 1000;
            pointer-events: none;
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            margin-bottom: 4px;
        }
        .covered:hover .tooltip,
        .uncovered:hover .tooltip {
            display: block;
        }
    </style>
</head>
"""
        ++ bodyString
        ++ """
</html>"""


getCoveredBackgroundColor : Maybe Int -> Int -> Int -> Maybe String
getCoveredBackgroundColor minCount maxCount count =
    case minCount of
        Nothing ->
            -- No non-zero counts, use CSS class only
            Nothing

        Just min ->
            if min == maxCount then
                -- All covered regions have same count, use CSS class only
                Nothing
            else if count <= 0 then
                -- Shouldn't happen for covered, but fallback to CSS class
                Nothing
            else
                -- Calculate percentage: (count - min) / (max - min) * 100
                let
                    percentage : Float
                    percentage =
                        if maxCount == min then
                            0
                        else
                            (toFloat (count - min) / toFloat (maxCount - min)) * 100

                    percentageStr : String
                    percentageStr =
                        String.fromFloat (roundTo 2 percentage)
                in
                -- Use color-mix: light green (#d4edda) for min coverage, dark green (#00cc00) for max coverage
                Just ("color-mix(in srgb, #00cc00 " ++ percentageStr ++ "%, #d4edda)")


renderAnnotatedLine : Int -> String -> List Annotation -> Maybe Int -> Int -> Html.Html msg
renderAnnotatedLine lineNum lineText annotations minCount maxCount =
    let
        sortedAnnotations : List Annotation
        sortedAnnotations =
            List.sortBy .column annotations

        -- Build segments: annotations mark where coverage changes
        -- Text from previous position to annotation.column gets the previous count's class
        -- Text from annotation.column onwards gets the annotation's count class
        -- Note: annotations use 1-indexed columns, but String.slice uses 0-indexed positions
        segments : List (Html.Html msg)
        segments =
            List.foldl
                (\annotation ( currentCol, currentCount, acc ) ->
                    let
                        segmentText : String
                        segmentText =
                            -- Convert 1-indexed columns to 0-indexed string positions
                            String.slice (currentCol - 1) (annotation.column - 1) lineText

                        previousClassName : String
                        previousClassName =
                            if currentCount == -1 then
                                "no-coverage"

                            else if currentCount == 0 then
                                "uncovered"

                            else
                                "covered"

                        segmentHtml : List (Html.Html msg)
                        segmentHtml =
                            if String.isEmpty segmentText then
                                []

                            else
                                let
                                    tooltipText : String
                                    tooltipText =
                                        if currentCount == -1 then
                                            ""

                                        else if currentCount == 0 then
                                            "0x"

                                        else
                                            String.fromInt currentCount ++ "x"

                                    spanAttrs : List (Html.Attribute msg)
                                    spanAttrs =
                                        if currentCount > 0 then
                                            -- Covered: use color-mix() for background if needed
                                            case getCoveredBackgroundColor minCount maxCount currentCount of
                                                Nothing ->
                                                    -- Use CSS class only
                                                    [ Attr.class previousClassName
                                                    ]

                                                Just colorValue ->
                                                    -- Use inline style with color-mix()
                                                    [ Attr.class previousClassName
                                                    , Attr.style "background-color" colorValue
                                                    ]
                                        else
                                            [ Attr.class previousClassName
                                            ]
                                in
                                if String.isEmpty tooltipText then
                                    [ Html.span spanAttrs [ Html.text segmentText ] ]

                                else
                                    [ Html.span spanAttrs
                                        [ Html.text segmentText
                                        , Html.span
                                            [ Attr.class "tooltip" ]
                                            [ Html.text tooltipText ]
                                        ]
                                    ]
                    in
                    ( annotation.column
                    , annotation.count
                    , acc ++ segmentHtml
                    )
                )
                ( 1, -1, [] )
                sortedAnnotations
                |> (\( lastCol, lastCount, acc ) ->
                        let
                            remainingText : String
                            remainingText =
                                -- Convert 1-indexed column to 0-indexed string position
                                String.slice (lastCol - 1) (String.length lineText) lineText

                            lastClassName : String
                            lastClassName =
                                if lastCount == -1 then
                                    "no-coverage"

                                else if lastCount == 0 then
                                    "uncovered"

                                else
                                    "covered"

                            remainingHtml : List (Html.Html msg)
                            remainingHtml =
                                if String.isEmpty remainingText then
                                    []

                                else
                                    let
                                        tooltipText : String
                                        tooltipText =
                                            if lastCount == -1 then
                                                ""

                                            else if lastCount == 0 then
                                                "0x"

                                            else
                                                String.fromInt lastCount ++ "x"

                                        spanAttrs : List (Html.Attribute msg)
                                        spanAttrs =
                                            if lastCount > 0 then
                                                -- Covered: use color-mix() for background if needed
                                                case getCoveredBackgroundColor minCount maxCount lastCount of
                                                    Nothing ->
                                                        -- Use CSS class only
                                                        [ Attr.class lastClassName
                                                        ]

                                                    Just colorValue ->
                                                        -- Use inline style with color-mix()
                                                        [ Attr.class lastClassName
                                                        , Attr.style "background-color" colorValue
                                                        ]
                                            else
                                                [ Attr.class lastClassName
                                                ]
                                    in
                                    if String.isEmpty tooltipText then
                                        [ Html.span spanAttrs [ Html.text remainingText ] ]

                                    else
                                        [ Html.span spanAttrs
                                            [ Html.text remainingText
                                            , Html.span
                                                [ Attr.class "tooltip" ]
                                                [ Html.text tooltipText ]
                                            ]
                                        ]
                        in
                        acc ++ remainingHtml
                   )
    in
    Html.span [] segments


roundTo : Int -> Float -> Float
roundTo decimals num =
    let
        multiplier : Float
        multiplier =
            10 ^ toFloat decimals
    in
    toFloat (round (num * multiplier)) / multiplier
