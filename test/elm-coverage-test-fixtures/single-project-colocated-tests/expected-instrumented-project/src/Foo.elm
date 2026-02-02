module Foo exposing (add, fooTest, multiply)

import Expect
import Test exposing (Test, test)
import Test.Coverage


fooTest : Test
fooTest =
    let
        _ =
            Test.Coverage.track
                1543203695
    in
    Test.describe "Foo"
        [ test "add works" <|
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            1529274156
                in
                add 2 3
                    |> Expect.equal 5
        , test "multiply works" <|
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            472339208
                in
                multiply 2 3
                    |> Expect.equal 6
        ]


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
