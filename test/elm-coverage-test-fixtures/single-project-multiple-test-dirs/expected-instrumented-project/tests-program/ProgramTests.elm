module ProgramTests exposing (suite)

import Expect
import Foo
import Test exposing (Test, test)
import Test.Coverage


suite : Test
suite =
    Test.describe "Foo program tests"
        [ test "divide works" <|
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            1001194990
                in
                Foo.divide 6 2
                    |> Expect.equal 3
        ]
