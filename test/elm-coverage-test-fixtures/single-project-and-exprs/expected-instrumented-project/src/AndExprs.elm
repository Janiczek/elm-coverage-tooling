module AndExprs exposing (fourAnd, nestedAnd, partiallyCoveredAnd, threeAnd, twoAnd)

import Test.Coverage



-- Two && expressions
-- Three && expressions
-- Four && expressions
-- Nested && expressions
-- Partially covered && (some short-circuits not tested)


partiallyCoveredAnd : Bool -> Bool -> Bool -> Bool
partiallyCoveredAnd a b c =
    let
        _ =
            Test.Coverage.track 1480054016
    in
    (let
        _ =
            Test.Coverage.track 1936701389
     in
     a
    )
        && (let
                _ =
                    Test.Coverage.track 1544038064
            in
            (let
                _ =
                    Test.Coverage.track 1445186520
             in
             b
            )
                && (let
                        _ =
                            Test.Coverage.track 1210511552
                    in
                    c
                   )
           )


nestedAnd : Bool -> Bool -> Bool -> Bool
nestedAnd a b c =
    let
        _ =
            Test.Coverage.track 1354194418
    in
    (let
        _ =
            Test.Coverage.track 1835917685
     in
     let
        _ =
            Test.Coverage.track 363207446
     in
     (let
        _ =
            Test.Coverage.track 1901138949
      in
      a
     )
        && (let
                _ =
                    Test.Coverage.track 1638831174
            in
            b
           )
    )
        && (let
                _ =
                    Test.Coverage.track 1439603479
            in
            let
                _ =
                    Test.Coverage.track 276167681
            in
            (let
                _ =
                    Test.Coverage.track 1808057903
             in
             b
            )
                && (let
                        _ =
                            Test.Coverage.track 433560039
                    in
                    c
                   )
           )


fourAnd : Bool -> Bool -> Bool -> Bool -> Bool
fourAnd a b c d =
    let
        _ =
            Test.Coverage.track 1126650764
    in
    (let
        _ =
            Test.Coverage.track 887363475
     in
     a
    )
        && (let
                _ =
                    Test.Coverage.track 166758503
            in
            (let
                _ =
                    Test.Coverage.track 130830751
             in
             b
            )
                && (let
                        _ =
                            Test.Coverage.track 1329744125
                    in
                    (let
                        _ =
                            Test.Coverage.track 1871913534
                     in
                     c
                    )
                        && (let
                                _ =
                                    Test.Coverage.track 1125738572
                            in
                            d
                           )
                   )
           )


threeAnd : Bool -> Bool -> Bool -> Bool
threeAnd a b c =
    let
        _ =
            Test.Coverage.track 293159333
    in
    (let
        _ =
            Test.Coverage.track 229768502
     in
     a
    )
        && (let
                _ =
                    Test.Coverage.track 1725827995
            in
            (let
                _ =
                    Test.Coverage.track 19184164
             in
             b
            )
                && (let
                        _ =
                            Test.Coverage.track 264149502
                    in
                    c
                   )
           )


twoAnd : Bool -> Bool -> Bool
twoAnd a b =
    let
        _ =
            Test.Coverage.track 1478858240
    in
    (let
        _ =
            Test.Coverage.track 1251956874
     in
     a
    )
        && (let
                _ =
                    Test.Coverage.track 529787006
            in
            b
           )



-- Three && expressions
-- Four && expressions
-- Nested && expressions
-- Partially covered && (some short-circuits not tested)
