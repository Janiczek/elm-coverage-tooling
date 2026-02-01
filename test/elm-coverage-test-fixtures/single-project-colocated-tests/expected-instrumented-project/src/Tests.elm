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
                482759411
    in
    (let
        _ =
            Test.Coverage.track 27547078
     in
     describe
    )
        (let
            _ =
                Test.Coverage.track 977344
         in
         "All tests"
        )
        (let
            _ =
                Test.Coverage.track
                    619009683
         in
         [ let
            _ =
                Test.Coverage.track 200966175
           in
           Foo.fooTest
         , let
            _ =
                Test.Coverage.track 1621808322
           in
           Bar.barTest
         ]
        )
