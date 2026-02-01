module Bar exposing (greet)

greet : String -> String
greet name =
    "Hello, " ++ name ++ "!"

farewell : String -> String
farewell name =
    "Goodbye, " ++ name ++ "!"
