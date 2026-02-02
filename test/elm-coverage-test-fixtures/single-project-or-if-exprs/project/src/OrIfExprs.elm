module OrIfExprs exposing (fullCoverage, onlyFoo1, onlyBar1, neitherFoo2, neitherBar2, finalElse)

-- Full coverage: all branches covered
fullCoverage : Int -> Int -> ()
fullCoverage foo bar =
    if foo == 1 || bar == 1 then
        ()
    else if foo == 2 || bar == 2 then
        ()
    else
        ()

-- Only foo == 1 path covered
onlyFoo1 : Int -> Int -> ()
onlyFoo1 foo bar =
    if foo == 1 || bar == 1 then
        ()
    else if foo == 2 || bar == 2 then
        ()
    else
        ()

-- Only bar == 1 path covered
onlyBar1 : Int -> Int -> ()
onlyBar1 foo bar =
    if foo == 1 || bar == 1 then
        ()
    else if foo == 2 || bar == 2 then
        ()
    else
        ()

-- Neither foo==1 nor bar==1, but foo==2 covered
neitherFoo2 : Int -> Int -> ()
neitherFoo2 foo bar =
    if foo == 1 || bar == 1 then
        ()
    else if foo == 2 || bar == 2 then
        ()
    else
        ()

-- Neither foo==1 nor bar==1, but bar==2 covered
neitherBar2 : Int -> Int -> ()
neitherBar2 foo bar =
    if foo == 1 || bar == 1 then
        ()
    else if foo == 2 || bar == 2 then
        ()
    else
        ()

-- Final else branch covered
finalElse : Int -> Int -> ()
finalElse foo bar =
    if foo == 1 || bar == 1 then
        ()
    else if foo == 2 || bar == 2 then
        ()
    else
        ()
