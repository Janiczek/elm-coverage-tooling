module UnitTests exposing (suite)

import Expect
import Foo
import Test exposing (Test, test)
import Test.Coverage


suite : Test
suite =
    let
        _ =
            Test.Coverage.track
                500012567
    in
    Test.describe "Foo unit tests"
        [ (let
            _ =
                Test.Coverage.track 64100879
           in
           test "add works"
          )
          <|
            let
                _ =
                    Test.Coverage.track
                        90767125
            in
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            200864303
                in
                Foo.add 2 3
                    |> Expect.equal 5
        ]
