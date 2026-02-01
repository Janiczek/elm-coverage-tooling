module Tests exposing (suite)

import BarTests
import FooTests
import Test exposing (Test, describe)

suite : Test
suite =
    describe "All tests"
        [ FooTests.suite
        , BarTests.suite
        ]
