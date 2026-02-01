module Bar exposing (greet)

import Test.Coverage


farewell : String -> String
farewell name =
    let
        _ =
            Test.Coverage.track 106420825
    in
    (let
        _ =
            Test.Coverage.track 1273732911
     in
     "Goodbye, "
    )
        ++ (let
                _ =
                    Test.Coverage.track 1522327402
            in
            (let
                _ =
                    Test.Coverage.track 33765320
             in
             name
            )
                ++ (let
                        _ =
                            Test.Coverage.track 473628016
                    in
                    "!"
                   )
           )


greet : String -> String
greet name =
    let
        _ =
            Test.Coverage.track 1871036766
    in
    (let
        _ =
            Test.Coverage.track 1678291280
     in
     "Hello, "
    )
        ++ (let
                _ =
                    Test.Coverage.track 1252470794
            in
            (let
                _ =
                    Test.Coverage.track 1295767476
             in
             name
            )
                ++ (let
                        _ =
                            Test.Coverage.track 1054626379
                    in
                    "!"
                   )
           )
