module Tests exposing (suite)

import Bar
import Foo
import Test exposing (Test, describe)
import Test.Coverage


suite : Test
suite =
    let
        _ =
            Test.Coverage.track
                200966175
    in
    describe "All tests"
        [ let
            _ =
                Test.Coverage.track 27547078
          in
          Foo.fooTest
        , let
            _ =
                Test.Coverage.track 977344
          in
          Bar.barTest
        ]
