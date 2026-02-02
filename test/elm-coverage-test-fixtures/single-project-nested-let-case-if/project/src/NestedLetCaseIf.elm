module NestedLetCaseIf exposing (nestedCaseOf, caseInLet, ifInLet, complexNested)

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
