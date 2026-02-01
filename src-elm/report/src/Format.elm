module Format exposing (Format(..), fromString)


type Format
    = Lcov
    | Html
    | Csv
    | Plaintext
    | Stdout


fromString : String -> Maybe Format
fromString str =
    case String.toLower str of
        "lcov" ->
            Just Lcov

        "html" ->
            Just Html

        "csv" ->
            Just Csv

        "plaintext" ->
            Just Plaintext

        "stdout" ->
            Just Stdout

        _ ->
            Nothing
