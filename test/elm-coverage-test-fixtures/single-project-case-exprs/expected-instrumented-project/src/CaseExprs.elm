module CaseExprs exposing (fourBranches, nestedCase, partiallyCoveredCase, threeBranches, twoBranches)

import Test.Coverage



-- Case with 2 branches
-- Case with 3 branches
-- Case with 4 branches
-- Nested case expressions
-- Partially covered case (some branches not tested)


partiallyCoveredCase : Int -> String
partiallyCoveredCase x =
    case x of
        0 ->
            let
                _ =
                    Test.Coverage.track 556273188
            in
            "zero"

        1 ->
            let
                _ =
                    Test.Coverage.track 1681273200
            in
            "one"

        2 ->
            let
                _ =
                    Test.Coverage.track 1721362682
            in
            "two"

        3 ->
            let
                _ =
                    Test.Coverage.track 1389476683
            in
            "three"

        _ ->
            let
                _ =
                    Test.Coverage.track 1090456675
            in
            "many"


nestedCase : Maybe (Result String Int) -> String
nestedCase maybeResult =
    case maybeResult of
        Just result ->
            case result of
                Ok value ->
                    let
                        _ =
                            Test.Coverage.track 390890205
                    in
                    "Got value: " ++ String.fromInt value

                Err msg ->
                    let
                        _ =
                            Test.Coverage.track 1428362492
                    in
                    "Got error: " ++ msg

        Nothing ->
            let
                _ =
                    Test.Coverage.track 1450626265
            in
            "No result"


fourBranches : Int -> String
fourBranches x =
    case x of
        0 ->
            let
                _ =
                    Test.Coverage.track 615386194
            in
            "zero"

        1 ->
            let
                _ =
                    Test.Coverage.track 285136691
            in
            "one"

        2 ->
            let
                _ =
                    Test.Coverage.track 293209453
            in
            "two"

        _ ->
            let
                _ =
                    Test.Coverage.track 562876422
            in
            "other"


threeBranches : Result String Int -> String
threeBranches result =
    case result of
        Ok value ->
            let
                _ =
                    Test.Coverage.track 785991995
            in
            "Success: " ++ String.fromInt value

        Err "error" ->
            let
                _ =
                    Test.Coverage.track 766807862
            in
            "Error occurred"

        Err other ->
            let
                _ =
                    Test.Coverage.track 1247320122
            in
            "Other error: " ++ other


twoBranches : Maybe Int -> Int
twoBranches maybe =
    case maybe of
        Just x ->
            let
                _ =
                    Test.Coverage.track 1140788623
            in
            x * 2

        Nothing ->
            let
                _ =
                    Test.Coverage.track 1706182870
            in
            0



-- Case with 3 branches
-- Case with 4 branches
-- Nested case expressions
-- Partially covered case (some branches not tested)
