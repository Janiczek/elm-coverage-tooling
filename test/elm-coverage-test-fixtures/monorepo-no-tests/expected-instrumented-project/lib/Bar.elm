module Bar exposing (greet)

import Test.Coverage


greet : String -> String
greet name =
    let
        _ =
            Test.Coverage.track 1678291280
    in
    "Hello, " ++ name ++ "!"
