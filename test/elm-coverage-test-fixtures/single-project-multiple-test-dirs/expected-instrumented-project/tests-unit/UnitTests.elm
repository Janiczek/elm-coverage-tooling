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
                743576369
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
        , (let
            _ =
                Test.Coverage.track 500012567
           in
           test "multiply works"
          )
          <|
            let
                _ =
                    Test.Coverage.track
                        1014602865
            in
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            872865296
                in
                Foo.multiply 2 3
                    |> Expect.equal 6
        ]
