module Foo exposing (add)

import Test.Coverage


subtract : Int -> Int -> Int
subtract a b =
    let
        _ =
            Test.Coverage.track 2010455107
    in
    a - b


add : Int -> Int -> Int
add a b =
    let
        _ =
            Test.Coverage.track 1568525173
    in
    a + b
