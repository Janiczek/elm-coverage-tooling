module NestedLetCaseIf exposing (nestedCaseOf, caseInLet, ifInLet, complexNested, ifInIf, caseInIf, letInIf, ifInCase, letInCase, letInLet, listWithCaseIfLet, tuple3WithCaseIfLet, recordWithCaseIfLet, recordUpdateWithCaseIfLet, recordWithPlainFields, parenthesizedCase, caseCasePipe, ifIfPipe, letLetPipe)

-- Nested case..of expressions
nestedCaseOf : Maybe (Result String Int) -> String
nestedCaseOf maybeResult =
    case maybeResult of
        Just result ->
            case result of
                Ok value ->
                    case value of
                        0 ->
                            "zero"
                        1 ->
                            "one"
                        _ ->
                            "other"
                Err msg ->
                    "error: " ++ msg
        Nothing ->
            "nothing"

-- case..of inside let-in body
caseInLet : Maybe Int -> Int -> Int
caseInLet maybeX y =
    let
        x =
            case maybeX of
                Just val ->
                    val
                Nothing ->
                    0
    in
    x + y

-- if-expr inside let-in body
ifInLet : Bool -> Int -> Int
ifInLet flag value =
    let
        multiplier =
            if flag then
                2
            else
                1
    in
    value * multiplier

-- Complex nested: let-in with case and if inside
complexNested : Maybe Int -> Bool -> String
complexNested maybeValue flag =
    let
        value =
            case maybeValue of
                Just x ->
                    x
                Nothing ->
                    0

        description =
            if flag then
                case value of
                    0 ->
                        "zero with flag"
                    1 ->
                        "one with flag"
                    _ ->
                        "other with flag"
            else
                case value of
                    0 ->
                        "zero without flag"
                    1 ->
                        "one without flag"
                    _ ->
                        "other without flag"
    in
    description

-- if inside if
ifInIf : Bool -> Bool -> String
ifInIf flag1 flag2 =
    if flag1 then
        if flag2 then
            "both true"
        else
            "first true"
    else
        if flag2 then
            "second true"
        else
            "both false"

-- case inside if
caseInIf : Bool -> Maybe Int -> String
caseInIf flag maybeValue =
    if flag then
        case maybeValue of
            Just x ->
                "flag true, value: " ++ String.fromInt x
            Nothing ->
                "flag true, no value"
    else
        case maybeValue of
            Just x ->
                "flag false, value: " ++ String.fromInt x
            Nothing ->
                "flag false, no value"

-- let inside if
letInIf : Bool -> Int -> Int
letInIf flag value =
    if flag then
        let
            multiplier = 2
            offset = 10
        in
        value * multiplier + offset
    else
        let
            multiplier = 1
            offset = 0
        in
        value * multiplier + offset

-- if inside case
ifInCase : Maybe Bool -> Int -> String
ifInCase maybeFlag value =
    case maybeFlag of
        Just flag ->
            if flag then
                "flag is true, value: " ++ String.fromInt value
            else
                "flag is false, value: " ++ String.fromInt value
        Nothing ->
            "no flag, value: " ++ String.fromInt value

-- let inside case
letInCase : Maybe Int -> Int -> Int
letInCase maybeX y =
    case maybeX of
        Just x ->
            let
                doubled = x * 2
                tripled = doubled + x
            in
            tripled + y
        Nothing ->
            let
                default = 0
                adjusted = default + 5
            in
            adjusted + y

-- let inside let
letInLet : Int -> Int -> Int
letInLet x y =
    let
        a =
            let
                doubled = x * 2
            in
            doubled
        b =
            let
                tripled = y * 3
            in
            tripled
    in
    a + b

-- list with case-of, if-expr, let-in as elements (only items tracked, not the list)
listWithCaseIfLet : Maybe Int -> Bool -> List Int
listWithCaseIfLet maybe b =
    [ case maybe of
        Just v ->
            v
        Nothing ->
            0
    , if b then
        1
      else
        2
    , let
        z = 1
      in
        z
    ]

-- tuple3 with case-of, if-expr, let-in as elements (only items tracked, not the tuple)
tuple3WithCaseIfLet : Maybe Int -> Bool -> ( Int, Int, Int )
tuple3WithCaseIfLet maybe b =
    ( case maybe of
        Just v ->
            v
        Nothing ->
            0
    , if b then
        1
      else
        2
    , let
        z = 1
      in
        z
    )

-- record with case-of, if-expr, let-in as field values (only fields tracked, not the record)
recordWithCaseIfLet : Maybe Int -> Bool -> { a : Int, b : Int, c : Int }
recordWithCaseIfLet maybe b =
    { a =
        case maybe of
            Just v ->
                v
            Nothing ->
                0
    , b =
        if b then
            1
        else
            2
    , c =
        let
            z = 1
        in
            z
    }

-- record update with case-of, if-expr, let-in as field values (only fields tracked, not the update)
recordUpdateWithCaseIfLet : { r | a : Int, b : Int, c : Int } -> Maybe Int -> Bool -> { a : Int, b : Int, c : Int }
recordUpdateWithCaseIfLet r maybe b =
    { r
        | a =
            case maybe of
                Just v ->
                    v
                Nothing ->
                    0
        , b =
            if b then
                1
            else
                2
        , c =
            let
                z = 1
            in
                z
    }

-- record with plain field values (application and operator; regression test for tracking)
recordWithPlainFields : Int -> { a : Int, b : Int }
recordWithPlainFields x =
    { a = identity x
    , b = x + 1
    }

-- declaration body is parenthesized case (only inner case tracked, not the parens)
parenthesizedCase : Maybe Int -> Int
parenthesizedCase maybe =
    ( case maybe of
        Just v ->
            v
        Nothing ->
            0
    )


-- Pipe case <| case and case |> case
caseCasePipe : Bool -> Maybe Int -> Maybe Int -> Bool -> ( Int, Int )
caseCasePipe b maybeX maybeY b2 =
    ( (case b of
        True ->
            identity
        False ->
            identity
      )
        <|
        (case maybeX of
            Just v ->
                v
            Nothing ->
                0
        )
    , (case maybeY of
        Just w ->
            w
        Nothing ->
            0
      )
        |>
        (case b2 of
            True ->
                identity
            False ->
                identity
        )
    )


-- Pipe if <| if and if |> if
ifIfPipe : Bool -> Bool -> Bool -> Bool -> ( Int, Int )
ifIfPipe b1 b2 b3 b4 =
    ( (if b1 then
        identity
      else
        identity
      )
        <|
        (if b2 then
            1
         else
            2
        )
    , (if b3 then
        3
      else
        4
      )
        |>
        (if b4 then
            identity
         else
            identity
        )
    )


-- Pipe let <| let and let |> let
letLetPipe : ( Int, Int )
letLetPipe =
    ( (let
        f = identity
      in
        f
      )
        <|
        (let
            x = 1
          in
            x
        )
    , (let
        y = 2
      in
        y
      )
        |>
        (let
            g = identity
          in
            g
        )
    )
