module CaseExprs exposing (fourBranches, nestedCase, partiallyCoveredCase, threeBranches, twoBranches)

import Test.Coverage



-- Case with 2 branches
-- Case with 3 branches
-- Case with 4 branches
-- Nested case expressions
-- Partially covered case (some branches not tested)


partiallyCoveredCase : Int -> String
partiallyCoveredCase x =
    case let
            _ =
                Test.Coverage.track 1387756282
        in
        x of
        0 ->
            let
                _ =
                    Test.Coverage.track 1058150396
            in
            "zero"

        1 ->
            let
                _ =
                    Test.Coverage.track 1040261944
            in
            "one"

        2 ->
            let
                _ =
                    Test.Coverage.track 804279791
            in
            "two"

        3 ->
            let
                _ =
                    Test.Coverage.track 1401696974
            in
            "three"

        _ ->
            let
                _ =
                    Test.Coverage.track 217307923
            in
            "many"


nestedCase : Maybe (Result String Int) -> String
nestedCase maybeResult =
    case let
            _ =
                Test.Coverage.track 31833927
        in
        maybeResult of
        Just result ->
            case let
                    _ =
                        Test.Coverage.track 1074704768
                in
                result of
                Ok value ->
                    let
                        _ =
                            Test.Coverage.track 863056653
                    in
                    (let
                        _ =
                            Test.Coverage.track 461394542
                     in
                     "Got value: "
                    )
                        ++ (let
                                _ =
                                    Test.Coverage.track 508839993
                            in
                            (let
                                _ =
                                    Test.Coverage.track 261017194
                             in
                             String.fromInt
                            )
                                (let
                                    _ =
                                        Test.Coverage.track 655176028
                                 in
                                 value
                                )
                           )

                Err msg ->
                    let
                        _ =
                            Test.Coverage.track 45664826
                    in
                    (let
                        _ =
                            Test.Coverage.track 140423761
                     in
                     "Got error: "
                    )
                        ++ (let
                                _ =
                                    Test.Coverage.track 580816458
                            in
                            msg
                           )

        Nothing ->
            let
                _ =
                    Test.Coverage.track 1815964016
            in
            "No result"


fourBranches : Int -> String
fourBranches x =
    case let
            _ =
                Test.Coverage.track 1389476683
        in
        x of
        0 ->
            let
                _ =
                    Test.Coverage.track 1090456675
            in
            "zero"

        1 ->
            let
                _ =
                    Test.Coverage.track 339233744
            in
            "one"

        2 ->
            let
                _ =
                    Test.Coverage.track 2007663582
            in
            "two"

        _ ->
            let
                _ =
                    Test.Coverage.track 1514252073
            in
            "other"


threeBranches : Result String Int -> String
threeBranches result =
    case let
            _ =
                Test.Coverage.track 615386194
        in
        result of
        Ok value ->
            let
                _ =
                    Test.Coverage.track 1428362492
            in
            (let
                _ =
                    Test.Coverage.track 285136691
             in
             "Success: "
            )
                ++ (let
                        _ =
                            Test.Coverage.track 390890205
                    in
                    (let
                        _ =
                            Test.Coverage.track 293209453
                     in
                     String.fromInt
                    )
                        (let
                            _ =
                                Test.Coverage.track 562876422
                         in
                         value
                        )
                   )

        Err "error" ->
            let
                _ =
                    Test.Coverage.track 1450626265
            in
            "Error occurred"

        Err other ->
            let
                _ =
                    Test.Coverage.track 1721362682
            in
            (let
                _ =
                    Test.Coverage.track 556273188
             in
             "Other error: "
            )
                ++ (let
                        _ =
                            Test.Coverage.track 1681273200
                    in
                    other
                   )


twoBranches : Maybe Int -> Int
twoBranches maybe =
    case let
            _ =
                Test.Coverage.track 1140788623
        in
        maybe of
        Just x ->
            let
                _ =
                    Test.Coverage.track 766807862
            in
            (let
                _ =
                    Test.Coverage.track 1706182870
             in
             x
            )
                * (let
                    _ =
                        Test.Coverage.track 785991995
                   in
                   2
                  )

        Nothing ->
            let
                _ =
                    Test.Coverage.track 1247320122
            in
            0



-- Case with 3 branches
-- Case with 4 branches
-- Nested case expressions
-- Partially covered case (some branches not tested)
