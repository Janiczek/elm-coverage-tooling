module ProgramTests exposing (suite)

import Expect
import Foo
import Test exposing (Test, test)

suite : Test
suite =
    Test.describe "Foo program tests"
        [ test "divide works" <|
            \_ ->
                Foo.divide 6 2
                    |> Expect.equal 3
        ]
