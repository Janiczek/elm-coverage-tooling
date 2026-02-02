module IntegrationTests exposing (suite)

import Bar
import Expect
import Test exposing (Test, test)
import Test.Coverage


suite : Test
suite =
    let
        _ =
            Test.Coverage.track
                1977586647
    in
    Test.describe "Bar integration tests"
        [ test "greet works" <|
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            731565934
                in
                Bar.greet "World"
                    |> Expect.equal "Hello, World!"
        ]
