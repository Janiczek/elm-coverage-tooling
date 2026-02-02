module Foo exposing (add, divide, multiply)

import Test.Coverage


divide : Int -> Int -> Int
divide a b =
    let
        _ =
            Test.Coverage.track 1529274156
    in
    a // b


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
