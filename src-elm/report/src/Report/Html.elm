module Report.Html exposing (generate)

import Dict exposing (Dict)
import Html.String as Html
import Html.String.Attributes as Attr
import PointMetadata exposing (PointMetadata)
import Report exposing (Input, ModuleStats, ReportFile)
import Sweep exposing (Annotation, Region)


generate : Input -> { reports : List ReportFile }
generate input =
    let
        modules : Dict String (List ( Int, PointMetadata ))
        modules =
            Dict.foldl
                (\pointId metadata acc ->
                    Dict.update metadata.moduleName
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
            Dict.foldl
                (\moduleName points acc ->
                    let
                        ( totalPoints, coveredPoints ) =
                            List.foldl
                                (\( pointId, _ ) ( total, covered ) ->
                                    let
                                        count : Int
                                        count =
                                            Dict.get pointId input.coverageData
                                                |> Maybe.withDefault 0
                                    in
                                    ( total + 1
                                    , if count > 0 then
                                        covered + 1

                                      else
                                        covered
                                    )
                                )
                                ( 0, 0 )
                                points

                        coveragePercentage : Float
                        coveragePercentage =
                            if totalPoints > 0 then
                                (toFloat coveredPoints / toFloat totalPoints) * 100

                            else
                                0
                    in
                    { moduleName = moduleName
                    , totalPoints = totalPoints
                    , coveredPoints = coveredPoints
                    , coveragePercentage = coveragePercentage
                    }
                        :: acc
                )
                []
                modules

        indexPage : ReportFile
        indexPage =
            { filepath = "index.html"
            , contents = generateIndexPage moduleStats
            }

        modulePages : List ReportFile
        modulePages =
                input.sources
                |>
            Dict.foldl
                (\moduleName sourceCode acc ->
                    let
                        modulePoints : List ( Int, PointMetadata )
                        modulePoints =
                            Dict.get moduleName modules
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

                        page : ReportFile
                        page =
                            { filepath = moduleName ++ ".html"
                            , contents = generateModulePage moduleName sourceCode regions
                            }
                    in
                    page :: acc
                )
                []
    in
    { reports = indexPage :: modulePages }


generateIndexPage : List ModuleStats -> String
generateIndexPage stats =
    let
        rows : List (Html.Html msg)
        rows =
            List.map
                (\stat ->
                    Html.tr []
                        [ Html.td []
                            [ Html.a [ Attr.href (stat.moduleName ++ ".html") ]
                                [ Html.text stat.moduleName ]
                            ]
                        , Html.td []
                            [ Html.text
                                (String.fromInt stat.coveredPoints
                                    ++ " / "
                                    ++ String.fromInt stat.totalPoints
                                    ++ " ("
                                    ++ String.fromFloat (roundTo 2 stat.coveragePercentage)
                                    ++ "%)"
                                )
                            ]
                        ]
                )
                stats

        bodyHtml : Html.Html msg
        bodyHtml =
            Html.div []
                [ Html.h1 [] [ Html.text "Coverage Report" ]
                , Html.table []
                    [ Html.thead []
                        [ Html.tr []
                            [ Html.th [] [ Html.text "Module" ]
                            , Html.th [] [ Html.text "Coverage" ]
                            ]
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


generateModulePage : String -> String -> List Region -> String
generateModulePage moduleName sourceCode regions =
    let
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
                                renderAnnotatedLine lineIndex lineText lineAnnotations
                    in
                    Html.tr []
                        [ Html.td [] [ Html.text (String.fromInt lineIndex) ]
                        , Html.td [] [ Html.pre [ ] [ renderedLine ] ]
                        ]
                )
                lines

        bodyHtml : Html.Html msg
        bodyHtml =
            Html.div []
                [ Html.h1 [] [ Html.text moduleName ]
                , Html.p []
                    [ Html.a [ Attr.href "index.html" ]
                        [ Html.text "← Back to index" ]
                    ]
                , Html.table [] renderedLines
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
        ++ moduleName
        ++ """ - Coverage Report</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        td { border: none; padding: 0; line-height: 1.2; }
        tr td:first-child { width: 1%; white-space: nowrap; padding-right: 8px; }
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


renderAnnotatedLine : Int -> String -> List Annotation -> Html.Html msg
renderAnnotatedLine lineNum lineText annotations =
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
