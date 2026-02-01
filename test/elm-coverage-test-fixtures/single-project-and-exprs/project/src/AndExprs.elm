module AndExprs exposing (twoAnd, threeAnd, fourAnd, nestedAnd, partiallyCoveredAnd)

-- Two && expressions
twoAnd : Bool -> Bool -> Bool
twoAnd a b =
    a && b

-- Three && expressions
threeAnd : Bool -> Bool -> Bool -> Bool
threeAnd a b c =
    a && b && c

-- Four && expressions
fourAnd : Bool -> Bool -> Bool -> Bool -> Bool
fourAnd a b c d =
    a && b && c && d

-- Nested && expressions
nestedAnd : Bool -> Bool -> Bool -> Bool
nestedAnd a b c =
    (a && b) && (b && c)

-- Partially covered && (some short-circuits not tested)
partiallyCoveredAnd : Bool -> Bool -> Bool -> Bool
partiallyCoveredAnd a b c =
    a && b && c
