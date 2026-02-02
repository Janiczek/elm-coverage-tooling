module Bar exposing (greet)

import Test.Coverage


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
