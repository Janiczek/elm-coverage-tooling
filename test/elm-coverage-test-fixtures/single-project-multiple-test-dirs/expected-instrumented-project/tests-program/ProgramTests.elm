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
                1346846593
    in
    (let
        _ =
            Test.Coverage.track 1001194990
     in
     Test.describe
    )
        (let
            _ =
                Test.Coverage.track 119922972
         in
         "Foo program tests"
        )
        (let
            _ =
                Test.Coverage.track
                    190348141
         in
         [ let
            _ =
                Test.Coverage.track
                    885362291
           in
           (let
                _ =
                    Test.Coverage.track 2095761139
            in
            (let
                _ =
                    Test.Coverage.track 728479469
             in
             test
            )
                (let
                    _ =
                        Test.Coverage.track 6585537
                 in
                 "divide works"
                )
           )
           <|
            (let
                _ =
                    Test.Coverage.track
                        816178306
             in
             \_ ->
                let
                    _ =
                        Test.Coverage.track
                            1267183074
                in
                (let
                    _ =
                        Test.Coverage.track 765745190
                 in
                 (let
                    _ =
                        Test.Coverage.track 669479839
                  in
                  Foo.divide
                 )
                    (let
                        _ =
                            Test.Coverage.track 1209814976
                     in
                     6
                    )
                    (let
                        _ =
                            Test.Coverage.track 1616267393
                     in
                     2
                    )
                )
                    |> (let
                            _ =
                                Test.Coverage.track 255446140
                        in
                        (let
                            _ =
                                Test.Coverage.track 1979884200
                         in
                         Expect.equal
                        )
                            (let
                                _ =
                                    Test.Coverage.track 1310489672
                             in
                             3
                            )
                       )
            )
         ]
        )
