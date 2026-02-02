module IfExprs exposing (complexIf, nestedIfs, partiallyCoveredIf, singleIf)

import Test.Coverage



-- Single if expression
-- Nested if expressions
-- Complex nested if
-- Partially covered if (some branches not tested)


partiallyCoveredIf : Bool -> Bool -> String
partiallyCoveredIf flag1 flag2 =
    if
        let
            _ =
                Test.Coverage.track 972215207
        in
        flag1
    then
        if
            let
                _ =
                    Test.Coverage.track 1192872092
            in
            flag2
        then
            let
                _ =
                    Test.Coverage.track 363063370
            in
            "both true"

        else
            let
                _ =
                    Test.Coverage.track 1999981276
            in
            "flag1 true, flag2 false"

    else
        let
            _ =
                Test.Coverage.track 1691405907
        in
        "flag1 false"


complexIf : Int -> Int -> Int -> String
complexIf a b c =
    if
        let
            _ =
                Test.Coverage.track 1859779131
        in
        a > 0
    then
        if
            let
                _ =
                    Test.Coverage.track 909342744
            in
            b > 0
        then
            if
                let
                    _ =
                        Test.Coverage.track 1220395682
                in
                c > 0
            then
                let
                    _ =
                        Test.Coverage.track 533113279
                in
                "all positive"

            else
                let
                    _ =
                        Test.Coverage.track 937987871
                in
                "a and b positive"

        else
            let
                _ =
                    Test.Coverage.track 1663934988
            in
            "only a positive"

    else
        let
            _ =
                Test.Coverage.track 2112286391
        in
        "a not positive"


nestedIfs : Int -> Int -> String
nestedIfs x y =
    if
        let
            _ =
                Test.Coverage.track 1605425470
        in
        x > 0
    then
        if
            let
                _ =
                    Test.Coverage.track 2138834269
            in
            y > 0
        then
            let
                _ =
                    Test.Coverage.track 742339696
            in
            "both positive"

        else
            let
                _ =
                    Test.Coverage.track 228959606
            in
            "x positive, y not"

    else if
        let
            _ =
                Test.Coverage.track 1946860432
        in
        y > 0
    then
        let
            _ =
                Test.Coverage.track 2013356303
        in
        "y positive, x not"

    else
        let
            _ =
                Test.Coverage.track 417254371
        in
        "both non-positive"


singleIf : Int -> String
singleIf x =
    if
        let
            _ =
                Test.Coverage.track 1507517779
        in
        x > 0
    then
        let
            _ =
                Test.Coverage.track 317346315
        in
        "positive"

    else
        let
            _ =
                Test.Coverage.track 1792477483
        in
        "non-positive"



-- Nested if expressions
-- Complex nested if
-- Partially covered if (some branches not tested)
