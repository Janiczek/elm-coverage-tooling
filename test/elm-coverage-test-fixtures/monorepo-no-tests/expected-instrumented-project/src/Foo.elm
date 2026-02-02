module Foo exposing (add)

import Test.Coverage


add : Int -> Int -> Int
add a b =
    let
        _ =
            Test.Coverage.track 1568525173
    in
    a + b
