module Sweep exposing (annotate, Annotation, Region)

import Dict exposing (Dict)
import List
import Range exposing (Position, Range)


type alias Region =
    { range : Range
    , count : Int
    }


type alias Annotation =
    { line : Int
    , column : Int
    , count : Int
    }


type Event
    = Start Region
    | End Region


{-| Annotates source code with coverage information using a sweep algorithm
to handle overlapping regions. Returns a list of annotations (line, column, count).

The algorithm:
1. Sort regions by start position (line, then column)
2. For each line, maintain active regions stack
3. Process columns left-to-right, adding/removing regions as they start/end
4. At each position, use the most specific (innermost/smallest) region's count

The sourceCode parameter should be a Dict mapping line numbers (1-indexed) to line content.
-}
annotate : Dict Int String -> List Region -> List Annotation
annotate sourceCode regions =
    let
        -- Group regions by line
        regionsByLine : Dict Int (List Region)
        regionsByLine =
            List.foldl
                (\region acc ->
                    let
                        startLine : Int
                        startLine =
                            region.range.start.row

                        endLine : Int
                        endLine =
                            region.range.end.row
                    in
                    List.range startLine endLine
                        |> List.foldl
                            (\line dict ->
                                Dict.update line
                                    (\maybeRegions ->
                                        case maybeRegions of
                                            Nothing ->
                                                Just [ region ]

                                            Just existing ->
                                                Just (region :: existing)
                                    )
                                    dict
                            )
                            acc
                )
                Dict.empty
                regions
    in
    Dict.foldl
        (\line lineRegions acc ->
            let
                lineContent : String
                lineContent =
                    Dict.get line sourceCode
                        |> Maybe.withDefault ""
            in
            annotateLine line lineContent lineRegions ++ acc
        )
        []
        regionsByLine
        |> List.reverse


annotateLine : Int -> String -> List Region -> List Annotation
annotateLine line lineContent regions =
    let
        lineLength : Int
        lineLength =
            String.length lineContent

        -- Find the first non-whitespace character position (1-indexed)
        -- Returns lineLength + 1 if the line is entirely whitespace
        firstNonWhitespaceCol : Int
        firstNonWhitespaceCol =
            let
                originalLength : Int
                originalLength =
                    String.length lineContent

                trimmedLength : Int
                trimmedLength =
                    String.length (String.trimLeft lineContent)
            in
            (originalLength - trimmedLength) + 1

        -- Find the last non-whitespace character position in a column range (1-indexed)
        -- startCol and endCol are both inclusive (1-indexed)
        -- Returns startCol - 1 if the entire range is whitespace
        findLastNonWhitespaceCol : Int -> Int -> Int
        findLastNonWhitespaceCol startCol endCol =
            let
                -- Convert to 0-indexed for string slicing
                startIdx : Int
                startIdx =
                    startCol - 1

                endIdx : Int
                endIdx =
                    endCol

                -- Get the substring for this range (endIdx is exclusive in String.slice)
                substring : String
                substring =
                    String.slice startIdx endIdx lineContent

                -- Find last non-whitespace character in substring by checking actual line content
                -- We need to check backwards from endCol to startCol
                findLastNonWhitespace : Int -> Int
                findLastNonWhitespace currentCol =
                    if currentCol < startCol then
                        -- No non-whitespace found, return startCol - 1
                        startCol - 1

                    else
                        let
                            -- Get character at currentCol (1-indexed)
                            charIdx : Int
                            charIdx =
                                currentCol - 1

                            char : String
                            char =
                                String.slice charIdx (charIdx + 1) lineContent
                        in
                        if char /= " " && char /= "\t" && char /= "\n" && char /= "\r" then
                            -- Found non-whitespace at currentCol
                            currentCol

                        else
                            -- Continue searching backwards
                            findLastNonWhitespace (currentCol - 1)
            in
            findLastNonWhitespace endCol

        -- Filter out regions that are entirely within leading whitespace
        -- A region is excluded if both its start and end on this line are before
        -- the first non-whitespace character
        filteredRegions : List Region
        filteredRegions =
            List.filter
                (\region ->
                    let
                        startCol : Int
                        startCol =
                            if region.range.start.row == line then
                                region.range.start.column

                            else
                                1

                        endCol : Int
                        endCol =
                            if region.range.end.row == line then
                                region.range.end.column

                            else
                                lineLength

                        -- Check if region is entirely within leading whitespace
                        -- Only exclude if both start and end are before first non-whitespace
                        -- AND the region actually starts/ends on this line (not continuing through)
                        isFullyWhitespace : Bool
                        isFullyWhitespace =
                            startCol < firstNonWhitespaceCol
                                && endCol < firstNonWhitespaceCol
                                && (region.range.start.row == line || region.range.end.row == line)
                    in
                    -- Include region if it's not fully within whitespace
                    not isFullyWhitespace
                )
                regions

        -- Create events: start and end of each region on this line
        -- Adjust startCol to skip leading whitespace if region starts in whitespace but extends beyond
        events : List ( Int, Event )
        events =
            List.concatMap
                (\region ->
                    let
                        startCol : Int
                        startCol =
                            if region.range.start.row == line then
                                region.range.start.column

                            else
                                1

                        endCol : Int
                        endCol =
                            if region.range.end.row == line then
                                region.range.end.column

                            else
                                lineLength

                        -- Clip startCol to firstNonWhitespaceCol if it starts in whitespace
                        -- but the region extends beyond whitespace
                        adjustedStartCol : Int
                        adjustedStartCol =
                            if startCol < firstNonWhitespaceCol && endCol >= firstNonWhitespaceCol then
                                firstNonWhitespaceCol

                            else
                                startCol
                    in
                    if region.range.end.row == line then
                        -- Region ends on this line: create both start and end events
                        [ ( adjustedStartCol, Start region )
                        , ( endCol + 1, End region )
                        ]

                    else if region.range.start.row == line then
                        -- Region starts on this line but continues: start event and end at end of line
                        -- (to mark where coverage ends on this line, even though region continues)
                        [ ( adjustedStartCol, Start region )
                        , ( lineLength + 1, End region )
                        ]

                    else
                        -- Region continues through this line: start at first non-whitespace
                        -- Don't create an End event - the region continues to the next line
                        -- Clip to skip leading whitespace on this line
                        [ ( firstNonWhitespaceCol, Start region )
                        ]
                )
                filteredRegions
                |> List.sortBy Tuple.first

        -- Process events to trim trailing whitespace from ending regions
        -- An End event needs trimming if:
        -- 1. The next event is not immediately adjacent (there's a gap)
        -- 2. The region ends on the current line
        adjustedEvents : List ( Int, Event )
        adjustedEvents =
            let
                processEvents : List ( Int, Event ) -> List ( Int, Event )
                processEvents eventList =
                    case eventList of
                        [] ->
                            []

                        [ ( col, event ) ] ->
                            -- Last event, check if it's an End that needs trimming
                            case event of
                                End region ->
                                    if region.range.end.row == line then
                                        -- Region ends on this line, check if we should trim
                                        let
                                            startCol : Int
                                            startCol =
                                                if region.range.start.row == line then
                                                    region.range.start.column

                                                else
                                                    1

                                            endCol : Int
                                            endCol =
                                                region.range.end.column

                                            trimmedEndCol : Int
                                            trimmedEndCol =
                                                findLastNonWhitespaceCol startCol endCol
                                        in
                                        -- Only trim if there's actually trailing whitespace
                                        if trimmedEndCol < endCol then
                                            [ ( trimmedEndCol + 1, End region ) ]

                                        else
                                            [ ( col, event ) ]

                                    else
                                        [ ( col, event ) ]

                                _ ->
                                    [ ( col, event ) ]

                        ( col, event ) :: ( nextCol, nextEvent ) :: rest ->
                            -- Check if current End event needs trimming
                            case event of
                                End region ->
                                    if region.range.end.row == line && nextCol > col + 1 then
                                        -- Region ends on this line and next event is not adjacent
                                        -- Trim trailing whitespace
                                        let
                                            startCol : Int
                                            startCol =
                                                if region.range.start.row == line then
                                                    region.range.start.column

                                                else
                                                    1

                                            endCol : Int
                                            endCol =
                                                region.range.end.column

                                            trimmedEndCol : Int
                                            trimmedEndCol =
                                                findLastNonWhitespaceCol startCol endCol
                                        in
                                        -- Only trim if there's actually trailing whitespace
                                        if trimmedEndCol < endCol then
                                            ( trimmedEndCol + 1, End region ) :: processEvents (( nextCol, nextEvent ) :: rest)

                                        else
                                            ( col, event ) :: processEvents (( nextCol, nextEvent ) :: rest)

                                    else
                                        ( col, event ) :: processEvents (( nextCol, nextEvent ) :: rest)

                                _ ->
                                    ( col, event ) :: processEvents (( nextCol, nextEvent ) :: rest)
            in
            processEvents events

        -- Sweep through columns, maintaining active regions
        -- Merge consecutive annotations with the same count as we go
        ( _, annotations ) =
            List.foldl
                (\( col, event ) ( activeRegions, acc ) ->
                    let
                        newActiveRegions : List Region
                        newActiveRegions =
                            case event of
                                Start region ->
                                    region :: activeRegions

                                End region ->
                                    List.filter (\r -> r /= region) activeRegions

                        -- Find the most specific (smallest) region
                        -- Use the minimum count (most specific = innermost)
                        count : Int
                        count =
                            case newActiveRegions of
                                [] ->
                                    -1
                                    -- -1 means no coverage info

                                first :: rest ->
                                    List.foldl (\r acc2 -> Basics.min r.count acc2) first.count rest

                        newAnnotation : Annotation
                        newAnnotation =
                            { line = line
                            , column = col
                            , count = count
                            }
                    in
                    -- Only add annotation if count differs from previous annotation
                    -- (merging consecutive annotations with same count)
                    case acc of
                        [] ->
                            -- First annotation: always add
                            ( newActiveRegions, [ newAnnotation ] )

                        lastAnnotation :: _ ->
                            if lastAnnotation.count == count then
                                -- Same count as previous: skip (merge)
                                ( newActiveRegions, acc )

                            else
                                -- Different count: add
                                ( newActiveRegions, newAnnotation :: acc )
                )
                ( [], [] )
                adjustedEvents
    in
    List.reverse annotations