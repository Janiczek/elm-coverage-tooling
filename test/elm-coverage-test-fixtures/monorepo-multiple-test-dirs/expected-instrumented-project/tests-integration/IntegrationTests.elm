module IntegrationTests exposing (suite)

import Bar
import Expect
import Test exposing (Test, test)
import Test.Coverage


suite : Test
suite =
    let
        _ =
            Test.Coverage.track
                1331104317
    in
    (let
        _ =
            Test.Coverage.track 731565934
     in
     Test.describe
    )
        (let
            _ =
                Test.Coverage.track 1977586647
         in
         "Bar integration tests"
        )
        (let
            _ =
                Test.Coverage.track
                    398129630
         in
         [ let
            _ =
                Test.Coverage.track
                    1284326578
           in
           (let
                _ =
                    Test.Coverage.track 42993546
            in
            (let
                _ =
                    Test.Coverage.track 1323402811
             in
             test
            )
                (let
                    _ =
                        Test.Coverage.track 651850139
                 in
                 "greet works"
                )
           )
           <|
            (let
                _ =
                    Test.Coverage.track
                        287637700
             in
             \_ ->
                let
                    _ =
                        Test.Coverage.track
                            1860925883
                in
                (let
                    _ =
                        Test.Coverage.track 1155629139
                 in
                 (let
                    _ =
                        Test.Coverage.track 1900956245
                  in
                  Bar.greet
                 )
                    (let
                        _ =
                            Test.Coverage.track 915305882
                     in
                     "World"
                    )
                )
                    |> (let
                            _ =
                                Test.Coverage.track 786744427
                        in
                        (let
                            _ =
                                Test.Coverage.track 1957654050
                         in
                         Expect.equal
                        )
                            (let
                                _ =
                                    Test.Coverage.track 1246225193
                             in
                             "Hello, World!"
                            )
                       )
            )
         ]
        )
