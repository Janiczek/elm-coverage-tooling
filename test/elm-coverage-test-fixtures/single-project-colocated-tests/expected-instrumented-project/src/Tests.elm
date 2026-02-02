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
                27547078
    in
    describe "All tests"
        [ Foo.fooTest
        , Bar.barTest
        ]
