module Foo exposing (add, fooTest, multiply)

import Expect
import Test exposing (Test, test)
import Test.Coverage


fooTest : Test
fooTest =
    let
        _ =
            Test.Coverage.track
                1433374326
    in
    (let
        _ =
            Test.Coverage.track 1326150844
     in
     Test.describe
    )
        (let
            _ =
                Test.Coverage.track 312029194
         in
         "Foo"
        )
        (let
            _ =
                Test.Coverage.track
                    699535814
         in
         [ let
            _ =
                Test.Coverage.track
                    1176968440
           in
           (let
                _ =
                    Test.Coverage.track 1982882392
            in
            (let
                _ =
                    Test.Coverage.track 1389335179
             in
             test
            )
                (let
                    _ =
                        Test.Coverage.track 960037092
                 in
                 "add works"
                )
           )
           <|
            (let
                _ =
                    Test.Coverage.track
                        1395133468
             in
             \_ ->
                let
                    _ =
                        Test.Coverage.track
                            987936747
                in
                (let
                    _ =
                        Test.Coverage.track 638302264
                 in
                 (let
                    _ =
                        Test.Coverage.track 1365081669
                  in
                  add
                 )
                    (let
                        _ =
                            Test.Coverage.track 2034365157
                     in
                     2
                    )
                    (let
                        _ =
                            Test.Coverage.track 1852283833
                     in
                     3
                    )
                )
                    |> (let
                            _ =
                                Test.Coverage.track 120735152
                        in
                        (let
                            _ =
                                Test.Coverage.track 731243182
                         in
                         Expect.equal
                        )
                            (let
                                _ =
                                    Test.Coverage.track 1657102471
                             in
                             5
                            )
                       )
            )
         , let
            _ =
                Test.Coverage.track
                    1584273081
           in
           (let
                _ =
                    Test.Coverage.track 785139579
            in
            (let
                _ =
                    Test.Coverage.track 541381121
             in
             test
            )
                (let
                    _ =
                        Test.Coverage.track 1709855543
                 in
                 "multiply works"
                )
           )
           <|
            (let
                _ =
                    Test.Coverage.track
                        1772567270
             in
             \_ ->
                let
                    _ =
                        Test.Coverage.track
                            1131483885
                in
                (let
                    _ =
                        Test.Coverage.track 463746766
                 in
                 (let
                    _ =
                        Test.Coverage.track 1107638296
                  in
                  multiply
                 )
                    (let
                        _ =
                            Test.Coverage.track 131043047
                     in
                     2
                    )
                    (let
                        _ =
                            Test.Coverage.track 2116421944
                     in
                     3
                    )
                )
                    |> (let
                            _ =
                                Test.Coverage.track 1576172087
                        in
                        (let
                            _ =
                                Test.Coverage.track 577156297
                         in
                         Expect.equal
                        )
                            (let
                                _ =
                                    Test.Coverage.track 696880320
                             in
                             6
                            )
                       )
            )
         ]
        )


subtract : Int -> Int -> Int
subtract a b =
    let
        _ =
            Test.Coverage.track 943683072
    in
    (let
        _ =
            Test.Coverage.track 253452108
     in
     a
    )
        - (let
            _ =
                Test.Coverage.track 72245905
           in
           b
          )


multiply : Int -> Int -> Int
multiply a b =
    let
        _ =
            Test.Coverage.track 1543203695
    in
    (let
        _ =
            Test.Coverage.track 1529274156
     in
     a
    )
        * (let
            _ =
                Test.Coverage.track 472339208
           in
           b
          )


add : Int -> Int -> Int
add a b =
    let
        _ =
            Test.Coverage.track 583025675
    in
    (let
        _ =
            Test.Coverage.track 1568525173
     in
     a
    )
        + (let
            _ =
                Test.Coverage.track 2010455107
           in
           b
          )
