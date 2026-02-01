module Bar exposing (greet)

import Test.Coverage


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
