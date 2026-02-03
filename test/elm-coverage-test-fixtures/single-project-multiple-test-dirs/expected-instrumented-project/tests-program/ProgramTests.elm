module ProgramTests exposing (suite)

import Expect
import Foo
import Test exposing (Test, test)
import Test.Coverage


suite : Test
suite =
    let
        _ =
            Test.Coverage.track
                6585537
    in
    Test.describe "Foo program tests"
        [ (let
            _ =
                Test.Coverage.track 1001194990
           in
           test "divide works"
          )
          <|
            let
                _ =
                    Test.Coverage.track
                        728479469
            in
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            119922972
                in
                Foo.divide 6 2
                    |> Expect.equal 3
        ]
