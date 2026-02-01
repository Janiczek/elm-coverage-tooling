module CaseExprs exposing (twoBranches, threeBranches, fourBranches, nestedCase, partiallyCoveredCase)

-- Case with 2 branches
twoBranches : Maybe Int -> Int
twoBranches maybe =
    case maybe of
        Just x ->
            x * 2
        Nothing ->
            0

-- Case with 3 branches
threeBranches : Result String Int -> String
threeBranches result =
    case result of
        Ok value ->
            "Success: " ++ String.fromInt value
        Err "error" ->
            "Error occurred"
        Err other ->
            "Other error: " ++ other

-- Case with 4 branches
fourBranches : Int -> String
fourBranches x =
    case x of
        0 ->
            "zero"
        1 ->
            "one"
        2 ->
            "two"
        _ ->
            "other"

-- Nested case expressions
nestedCase : Maybe (Result String Int) -> String
nestedCase maybeResult =
    case maybeResult of
        Just result ->
            case result of
                Ok value ->
                    "Got value: " ++ String.fromInt value
                Err msg ->
                    "Got error: " ++ msg
        Nothing ->
            "No result"

-- Partially covered case (some branches not tested)
partiallyCoveredCase : Int -> String
partiallyCoveredCase x =
    case x of
        0 ->
            "zero"
        1 ->
            "one"
        2 ->
            "two"
        3 ->
            "three"
        _ ->
            "many"
