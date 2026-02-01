module Tests exposing (suite)

import Bar
import Foo
import Test exposing (Test, describe)

suite : Test
suite =
    describe "All tests"
        [ Foo.fooTest
        , Bar.barTest
        ]
