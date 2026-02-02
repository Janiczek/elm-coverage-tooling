module Foo exposing (add, multiply)

import Test.Coverage


subtract : Int -> Int -> Int
subtract a b =
    let
        _ =
            Test.Coverage.track 583025675
    in
    a - b


multiply : Int -> Int -> Int
multiply a b =
    let
        _ =
            Test.Coverage.track 2010455107
    in
    a * b


add : Int -> Int -> Int
add a b =
    let
        _ =
            Test.Coverage.track 1568525173
    in
    a + b
