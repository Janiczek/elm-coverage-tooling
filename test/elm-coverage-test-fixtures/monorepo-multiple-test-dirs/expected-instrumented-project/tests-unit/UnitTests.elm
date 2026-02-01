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
                1486785218
    in
    (let
        _ =
            Test.Coverage.track 64100879
     in
     Test.describe
    )
        (let
            _ =
                Test.Coverage.track 200864303
         in
         "Foo unit tests"
        )
        (let
            _ =
                Test.Coverage.track
                    490593012
         in
         [ let
            _ =
                Test.Coverage.track
                    1437954710
           in
           (let
                _ =
                    Test.Coverage.track 872865296
            in
            (let
                _ =
                    Test.Coverage.track 90767125
             in
             test
            )
                (let
                    _ =
                        Test.Coverage.track 500012567
                 in
                 "add works"
                )
           )
           <|
            (let
                _ =
                    Test.Coverage.track
                        1216230753
             in
             \_ ->
                let
                    _ =
                        Test.Coverage.track
                            1956108682
                in
                (let
                    _ =
                        Test.Coverage.track 1909674311
                 in
                 (let
                    _ =
                        Test.Coverage.track 1014602865
                  in
                  Foo.add
                 )
                    (let
                        _ =
                            Test.Coverage.track 743576369
                     in
                     2
                    )
                    (let
                        _ =
                            Test.Coverage.track 1770131270
                     in
                     3
                    )
                )
                    |> (let
                            _ =
                                Test.Coverage.track 240111545
                        in
                        (let
                            _ =
                                Test.Coverage.track 84941532
                         in
                         Expect.equal
                        )
                            (let
                                _ =
                                    Test.Coverage.track 1199532509
                             in
                             5
                            )
                       )
            )
         ]
        )
