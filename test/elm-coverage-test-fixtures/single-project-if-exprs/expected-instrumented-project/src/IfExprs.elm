module IfExprs exposing (complexIf, nestedIfs, partiallyCoveredIf, singleIf)

import Test.Coverage



-- Single if expression
-- Nested if expressions
-- Complex nested if
-- Partially covered if (some branches not tested)


partiallyCoveredIf : Bool -> Bool -> String
partiallyCoveredIf flag1 flag2 =
    let
        _ =
            Test.Coverage.track
                938945759
    in
    if
        let
            _ =
                Test.Coverage.track 839219528
        in
        flag1
    then
        let
            _ =
                Test.Coverage.track
                    34170184
        in
        if
            let
                _ =
                    Test.Coverage.track 1148138641
            in
            flag2
        then
            let
                _ =
                    Test.Coverage.track 1626222467
            in
            "both true"

        else
            let
                _ =
                    Test.Coverage.track 2003557405
            in
            "flag1 true, flag2 false"

    else
        let
            _ =
                Test.Coverage.track 1771906230
        in
        "flag1 false"


complexIf : Int -> Int -> Int -> String
complexIf a b c =
    let
        _ =
            Test.Coverage.track
                1206625727
    in
    if
        let
            _ =
                Test.Coverage.track 1650503881
        in
        (let
            _ =
                Test.Coverage.track 923162716
         in
         a
        )
            > (let
                _ =
                    Test.Coverage.track 1434335125
               in
               0
              )
    then
        let
            _ =
                Test.Coverage.track
                    1313964057
        in
        if
            let
                _ =
                    Test.Coverage.track 1016519538
            in
            (let
                _ =
                    Test.Coverage.track 1098004037
             in
             b
            )
                > (let
                    _ =
                        Test.Coverage.track 1989747802
                   in
                   0
                  )
        then
            let
                _ =
                    Test.Coverage.track
                        2079073711
            in
            if
                let
                    _ =
                        Test.Coverage.track 478776050
                in
                (let
                    _ =
                        Test.Coverage.track 723831276
                 in
                 c
                )
                    > (let
                        _ =
                            Test.Coverage.track 2073228654
                       in
                       0
                      )
            then
                let
                    _ =
                        Test.Coverage.track 646224474
                in
                "all positive"

            else
                let
                    _ =
                        Test.Coverage.track 1348247873
                in
                "a and b positive"

        else
            let
                _ =
                    Test.Coverage.track 238562744
            in
            "only a positive"

    else
        let
            _ =
                Test.Coverage.track 20575268
        in
        "a not positive"


nestedIfs : Int -> Int -> String
nestedIfs x y =
    let
        _ =
            Test.Coverage.track
                1691405907
    in
    if
        let
            _ =
                Test.Coverage.track 2013356303
        in
        (let
            _ =
                Test.Coverage.track 228959606
         in
         x
        )
            > (let
                _ =
                    Test.Coverage.track 1946860432
               in
               0
              )
    then
        let
            _ =
                Test.Coverage.track
                    937987871
        in
        if
            let
                _ =
                    Test.Coverage.track 909342744
            in
            (let
                _ =
                    Test.Coverage.track 417254371
             in
             y
            )
                > (let
                    _ =
                        Test.Coverage.track 1859779131
                   in
                   0
                  )
        then
            let
                _ =
                    Test.Coverage.track 1220395682
            in
            "both positive"

        else
            let
                _ =
                    Test.Coverage.track 533113279
            in
            "x positive, y not"

    else
        let
            _ =
                Test.Coverage.track
                    1999981276
        in
        if
            let
                _ =
                    Test.Coverage.track 972215207
            in
            (let
                _ =
                    Test.Coverage.track 1663934988
             in
             y
            )
                > (let
                    _ =
                        Test.Coverage.track 2112286391
                   in
                   0
                  )
        then
            let
                _ =
                    Test.Coverage.track 1192872092
            in
            "y positive, x not"

        else
            let
                _ =
                    Test.Coverage.track 363063370
            in
            "both non-positive"


singleIf : Int -> String
singleIf x =
    let
        _ =
            Test.Coverage.track
                742339696
    in
    if
        let
            _ =
                Test.Coverage.track 1792477483
        in
        (let
            _ =
                Test.Coverage.track 1507517779
         in
         x
        )
            > (let
                _ =
                    Test.Coverage.track 317346315
               in
               0
              )
    then
        let
            _ =
                Test.Coverage.track 1605425470
        in
        "positive"

    else
        let
            _ =
                Test.Coverage.track 2138834269
        in
        "non-positive"



-- Nested if expressions
-- Complex nested if
-- Partially covered if (some branches not tested)
