module Foo exposing (add, multiply, fooTest)

import Expect
import Test exposing (Test, test)

add : Int -> Int -> Int
add a b =
    a + b

multiply : Int -> Int -> Int
multiply a b =
    a * b

subtract : Int -> Int -> Int
subtract a b =
    a - b

fooTest : Test
fooTest =
    Test.describe "Foo"
        [ test "add works" <|
            \_ ->
                add 2 3
                    |> Expect.equal 5
        , test "multiply works" <|
            \_ ->
                multiply 2 3
                    |> Expect.equal 6
        ]
