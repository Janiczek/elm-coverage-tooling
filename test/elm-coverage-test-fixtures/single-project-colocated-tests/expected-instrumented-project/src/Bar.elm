module Bar exposing (barTest, greet)

import Expect
import Test exposing (Test, test)
import Test.Coverage


barTest : Test
barTest =
    Test.describe "Bar"
        [ test "greet works" <|
            \_ ->
                let
                    _ =
                        Test.Coverage.track
                            1054626379
                in
                greet "World"
                    |> Expect.equal "Hello, World!"
        ]


farewell : String -> String
farewell name =
    let
        _ =
            Test.Coverage.track 1295767476
    in
    "Goodbye, " ++ name ++ "!"


greet : String -> String
greet name =
    let
        _ =
            Test.Coverage.track 1678291280
    in
    "Hello, " ++ name ++ "!"
