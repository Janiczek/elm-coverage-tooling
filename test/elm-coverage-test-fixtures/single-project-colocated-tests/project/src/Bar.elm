module Bar exposing (greet, barTest)

import Expect
import Test exposing (Test, test)

greet : String -> String
greet name =
    "Hello, " ++ name ++ "!"

farewell : String -> String
farewell name =
    "Goodbye, " ++ name ++ "!"

barTest : Test
barTest =
    Test.describe "Bar"
        [ test "greet works" <|
            \_ ->
                greet "World"
                    |> Expect.equal "Hello, World!"
        ]
