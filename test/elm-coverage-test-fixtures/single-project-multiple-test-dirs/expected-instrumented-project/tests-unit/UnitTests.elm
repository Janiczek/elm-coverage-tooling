module UnitTests exposing (suite)

import Expect
import Foo
import Test exposing (Test, test)
import Test.Coverage


suite : Test
suite =
    Test.describe "Foo unit tests"
        [ test "add works" <|
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            200864303
                in
                Foo.add 2 3
                    |> Expect.equal 5
        , test "multiply works" <|
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            64100879
                in
                Foo.multiply 2 3
                    |> Expect.equal 6
        ]
