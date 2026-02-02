module IfExprs exposing (complexIf, nestedIfs, partiallyCoveredIf, singleIf)

import Test.Coverage



-- Single if expression
-- Nested if expressions
-- Complex nested if
-- Partially covered if (some branches not tested)


partiallyCoveredIf : Bool -> Bool -> String
partiallyCoveredIf flag1 flag2 =
    if flag1 then
        if flag2 then
            let
                _ =
                    Test.Coverage.track 1859779131
            in
            "both true"

        else
            let
                _ =
                    Test.Coverage.track 909342744
            in
            "flag1 true, flag2 false"

    else
        let
            _ =
                Test.Coverage.track 1220395682
        in
        "flag1 false"


complexIf : Int -> Int -> Int -> String
complexIf a b c =
    if a > 0 then
        if b > 0 then
            if c > 0 then
                let
                    _ =
                        Test.Coverage.track 228959606
                in
                "all positive"

            else
                let
                    _ =
                        Test.Coverage.track 1946860432
                in
                "a and b positive"

        else
            let
                _ =
                    Test.Coverage.track 2013356303
            in
            "only a positive"

    else
        let
            _ =
                Test.Coverage.track 417254371
        in
        "a not positive"


nestedIfs : Int -> Int -> String
nestedIfs x y =
    if x > 0 then
        if y > 0 then
            let
                _ =
                    Test.Coverage.track 1792477483
            in
            "both positive"

        else
            let
                _ =
                    Test.Coverage.track 1605425470
            in
            "x positive, y not"

    else if y > 0 then
        let
            _ =
                Test.Coverage.track 2138834269
        in
        "y positive, x not"

    else
        let
            _ =
                Test.Coverage.track 742339696
        in
        "both non-positive"


singleIf : Int -> String
singleIf x =
    if x > 0 then
        let
            _ =
                Test.Coverage.track 1507517779
        in
        "positive"

    else
        let
            _ =
                Test.Coverage.track 317346315
        in
        "non-positive"



-- Nested if expressions
-- Complex nested if
-- Partially covered if (some branches not tested)
