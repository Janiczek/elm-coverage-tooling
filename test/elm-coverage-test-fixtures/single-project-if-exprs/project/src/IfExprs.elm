module IfExprs exposing (singleIf, nestedIfs, complexIf, partiallyCoveredIf)

-- Single if expression
singleIf : Int -> String
singleIf x =
    if x > 0 then
        "positive"
    else
        "non-positive"

-- Nested if expressions
nestedIfs : Int -> Int -> String
nestedIfs x y =
    if x > 0 then
        if y > 0 then
            "both positive"
        else
            "x positive, y not"
    else
        if y > 0 then
            "y positive, x not"
        else
            "both non-positive"

-- Complex nested if
complexIf : Int -> Int -> Int -> String
complexIf a b c =
    if a > 0 then
        if b > 0 then
            if c > 0 then
                "all positive"
            else
                "a and b positive"
        else
            "only a positive"
    else
        "a not positive"

-- Partially covered if (some branches not tested)
partiallyCoveredIf : Bool -> Bool -> String
partiallyCoveredIf flag1 flag2 =
    if flag1 then
        if flag2 then
            "both true"
        else
            "flag1 true, flag2 false"
    else
        "flag1 false"
