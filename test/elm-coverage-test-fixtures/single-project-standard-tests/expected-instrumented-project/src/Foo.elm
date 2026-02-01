module Foo exposing (add, multiply)

import Test.Coverage


subtract : Int -> Int -> Int
subtract a b =
    let
        _ =
            Test.Coverage.track 943683072
    in
    (let
        _ =
            Test.Coverage.track 253452108
     in
     a
    )
        - (let
            _ =
                Test.Coverage.track 72245905
           in
           b
          )


multiply : Int -> Int -> Int
multiply a b =
    let
        _ =
            Test.Coverage.track 1543203695
    in
    (let
        _ =
            Test.Coverage.track 1529274156
     in
     a
    )
        * (let
            _ =
                Test.Coverage.track 472339208
           in
           b
          )


add : Int -> Int -> Int
add a b =
    let
        _ =
            Test.Coverage.track 583025675
    in
    (let
        _ =
            Test.Coverage.track 1568525173
     in
     a
    )
        + (let
            _ =
                Test.Coverage.track 2010455107
           in
           b
          )
