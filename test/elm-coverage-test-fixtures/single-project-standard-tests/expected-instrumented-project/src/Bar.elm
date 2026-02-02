module Bar exposing (x)

import Test.Coverage


x a =
    let
        _ =
            Test.Coverage.track 1678291280
    in
    1
