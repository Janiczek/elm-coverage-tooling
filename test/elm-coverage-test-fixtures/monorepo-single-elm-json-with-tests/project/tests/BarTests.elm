module BarTests exposing (suite)

import Bar
import Expect
import Test exposing (Test, test)

suite : Test
suite =
    Test.describe "Bar"
        [ test "greet works" <|
            \_ ->
                Bar.greet "World"
                    |> Expect.equal "Hello, World!"
        ]
