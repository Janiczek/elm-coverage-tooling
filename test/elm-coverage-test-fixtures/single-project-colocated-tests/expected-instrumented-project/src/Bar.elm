module Bar exposing (barTest, greet)

import Expect
import Test exposing (Test, test)
import Test.Coverage


barTest : Test
barTest =
    let
        _ =
            Test.Coverage.track
                1998419612
    in
    (let
        _ =
            Test.Coverage.track 2092670002
     in
     Test.describe
    )
        (let
            _ =
                Test.Coverage.track 763229621
         in
         "Bar"
        )
        (let
            _ =
                Test.Coverage.track
                    66147215
         in
         [ let
            _ =
                Test.Coverage.track
                    1036955255
           in
           (let
                _ =
                    Test.Coverage.track 1832804532
            in
            (let
                _ =
                    Test.Coverage.track 227846454
             in
             test
            )
                (let
                    _ =
                        Test.Coverage.track 1890083770
                 in
                 "greet works"
                )
           )
           <|
            (let
                _ =
                    Test.Coverage.track
                        989525643
             in
             \_ ->
                let
                    _ =
                        Test.Coverage.track
                            1930637772
                in
                (let
                    _ =
                        Test.Coverage.track 147793955
                 in
                 (let
                    _ =
                        Test.Coverage.track 1176468248
                  in
                  greet
                 )
                    (let
                        _ =
                            Test.Coverage.track 1128740717
                     in
                     "World"
                    )
                )
                    |> (let
                            _ =
                                Test.Coverage.track 761048117
                        in
                        (let
                            _ =
                                Test.Coverage.track 203617728
                         in
                         Expect.equal
                        )
                            (let
                                _ =
                                    Test.Coverage.track 159263429
                             in
                             "Hello, World!"
                            )
                       )
            )
         ]
        )


farewell : String -> String
farewell name =
    let
        _ =
            Test.Coverage.track 106420825
    in
    (let
        _ =
            Test.Coverage.track 1273732911
     in
     "Goodbye, "
    )
        ++ (let
                _ =
                    Test.Coverage.track 1522327402
            in
            (let
                _ =
                    Test.Coverage.track 33765320
             in
             name
            )
                ++ (let
                        _ =
                            Test.Coverage.track 473628016
                    in
                    "!"
                   )
           )


greet : String -> String
greet name =
    let
        _ =
            Test.Coverage.track 1871036766
    in
    (let
        _ =
            Test.Coverage.track 1678291280
     in
     "Hello, "
    )
        ++ (let
                _ =
                    Test.Coverage.track 1252470794
            in
            (let
                _ =
                    Test.Coverage.track 1295767476
             in
             name
            )
                ++ (let
                        _ =
                            Test.Coverage.track 1054626379
                    in
                    "!"
                   )
           )
