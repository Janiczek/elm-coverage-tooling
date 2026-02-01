module UnitTests exposing (suite)

import Expect
import Foo
import Test exposing (Test, test)


suite : Test
suite =
    Test.describe "Foo unit tests"
        [ test "add works" <|
            \_ ->
                Foo.add 2 3
                    |> Expect.equal 5
        ]
