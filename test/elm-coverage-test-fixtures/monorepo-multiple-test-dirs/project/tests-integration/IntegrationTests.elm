module IntegrationTests exposing (suite)

import Bar
import Expect
import Test exposing (Test, test)


suite : Test
suite =
    Test.describe "Bar integration tests"
        [ test "greet works" <|
            \_ ->
                Bar.greet "World"
                    |> Expect.equal "Hello, World!"
        ]
