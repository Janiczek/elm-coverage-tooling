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
                651850139
    in
    Test.describe "Bar integration tests"
        [ (let
            _ =
                Test.Coverage.track 731565934
           in
           test "greet works"
          )
          <|
            let
                _ =
                    Test.Coverage.track
                        1323402811
            in
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            1977586647
                in
                Bar.greet "World"
                    |> Expect.equal "Hello, World!"
        ]
