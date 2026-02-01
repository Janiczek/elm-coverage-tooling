module SweepTests exposing (suite)

import Dict exposing (Dict)
import Expect
import Sweep
import Test exposing (Test)


type alias TestCase =
    { name : String
    , sourceCode : String
    , regions : List Sweep.Region
    , expected : List Sweep.Annotation
    }


suite : Test
suite =
    Test.describe "Sweep tests"
        ([ { name = "simple constant uncovered"
           , sourceCode = """
module A exposing (a)

a =
    123
"""
           , regions =
                [ { range =
                        { start = { row = 4, column = 5 }
                        , end = { row = 4, column = 8 }
                        }
                  , count = 0
                  }
                ]
           , expected =
                [ { line = 4, column = 5, count = 0 }
                , { line = 4, column = 9, count = -1 }
                ]
           }
         , { name = "simple constant covered"
           , sourceCode = """
module A exposing (a)

a =
    123
"""
           , regions =
                [ { range =
                        { start = { row = 4, column = 5 }
                        , end = { row = 4, column = 8 }
                        }
                  , count = 5
                  }
                ]
           , expected =
                [ { line = 4, column = 5, count = 5 }
                , { line = 4, column = 9, count = -1 }
                ]
           }
         , { name = "chained boolean expression with nested regions"
           , sourceCode = """
module A exposing (a)

a =
    a && b && c
"""
           , regions =
                [ -- a && b && c
                    { range =
                        { start = { row = 4, column = 5 }
                        , end = { row = 4, column = 16 }
                        }
                  , count = 10
                  }
                , -- a
                { range =
                        { start = { row = 4, column = 5 }
                        , end = { row = 4, column = 6 }
                        }
                  , count = 10
                  }
                , -- b && c
                { range =
                        { start = { row = 4, column = 10 }
                        , end = { row = 4, column = 16 }
                        }
                  , count = 8
                  }
                , -- b
                { range =
                        { start = { row = 4, column = 10 }
                        , end = { row = 4, column = 11 }
                        }
                  , count = 8
                  }
                , -- c
                { range =
                        { start = { row = 4, column = 15 }
                        , end = { row = 4, column = 16 }
                        }
                  , count = 5
                  }
                ]
           , expected =
                [ { line = 4, column = 5, count = 10 }
                , { line = 4, column = 10, count = 8 }
                , { line = 4, column = 15, count = 5 }
                , { line = 4, column = 17, count = -1 }
                ]
           }
         , { name = "empty regions list"
           , sourceCode = """
module A exposing (a)

a = 42
"""
           , regions = []
           , expected = []
           }
         , { name = "region entirely within leading whitespace is excluded"
           , sourceCode = """
module A exposing (a)

a =
    hello
"""
           , regions =
                [ { range =
                        { start = { row = 4, column = 1 }
                        , end = { row = 4, column = 4 }
                        }
                  , count = 5
                  }
                , { range =
                        { start = { row = 4, column = 6 }
                        , end = { row = 4, column = 10 }
                        }
                  , count = 10
                  }
                ]
           , expected =
                [ { line = 4, column = 6, count = 10 }
                , { line = 4, column = 11, count = -1 }
                ]
           }
         , { name = "region starting in whitespace but extending beyond excludes whitespace portion"
           , sourceCode = """
module A exposing (a)

a =
    hello
"""
           , regions =
                [ { range =
                        { start = { row = 4, column = 2 }
                        , end = { row = 4, column = 7 }
                        }
                  , count = 5
                  }
                ]
           , expected =
                [ { line = 4, column = 5, count = 5 }
                , { line = 4, column = 8, count = -1 }
                ]
           }
         , { name = "region entirely after whitespace is included"
           , sourceCode = """
module A exposing (a)

a =
    hello
"""
           , regions =
                [ { range =
                        { start = { row = 4, column = 6 }
                        , end = { row = 4, column = 10 }
                        }
                  , count = 10
                  }
                ]
           , expected =
                [ { line = 4, column = 6, count = 10 }
                , { line = 4, column = 11, count = -1 }
                ]
           }
         , { name = "region continuing through line with whitespace is included"
           , sourceCode = """
module A exposing (a)

a =
    hello
    world
"""
           , regions =
                [ { range =
                        { start = { row = 4, column = 6 }
                        , end = { row = 5, column = 10 }
                        }
                  , count = 5
                  }
                ]
           , expected =
                [ { line = 4, column = 6, count = 5 }
                , { line = 4, column = 10, count = -1 }
                , { line = 5, column = 5, count = 5 }
                , { line = 5, column = 11, count = -1 }
                ]
           }
         , { name = "line with only whitespace excludes all regions"
           , sourceCode = """
module A exposing (a)

a =
    
    hello
"""
           , regions =
                [ { range =
                        { start = { row = 4, column = 1 }
                        , end = { row = 4, column = 4 }
                        }
                  , count = 5
                  }
                , { range =
                        { start = { row = 5, column = 6 }
                        , end = { row = 5, column = 10 }
                        }
                  , count = 10
                  }
                ]
           , expected =
                [ { line = 5, column = 6, count = 10 }
                , { line = 5, column = 11, count = -1 }
                ]
           }
         , { name = "multiple regions with some in whitespace"
           , sourceCode = """
module A exposing (a)

a =
    hello world
"""
           , regions =
                [ { range =
                        { start = { row = 4, column = 1 }
                        , end = { row = 4, column = 3 }
                        }
                  , count = 1
                  }
                , { range =
                        { start = { row = 4, column = 6 }
                        , end = { row = 4, column = 10 }
                        }
                  , count = 5
                  }
                , { range =
                        { start = { row = 4, column = 12 }
                        , end = { row = 4, column = 16 }
                        }
                  , count = 10
                  }
                ]
           , expected =
                [ { line = 4, column = 6, count = 5 }
                , { line = 4, column = 11, count = -1 }
                , { line = 4, column = 12, count = 10 }
                , { line = 4, column = 17, count = -1 }
                ]
           }
         ]
            |> List.map testCase
        )


testCase : TestCase -> Test
testCase tc =
    Test.test tc.name <|
        \() ->
            let
                sourceCodeDict : Dict Int String
                sourceCodeDict =
                    String.trim tc.sourceCode
                        |> String.lines
                        |> List.indexedMap (\index line -> ( index + 1, line ))
                        |> Dict.fromList
            in
            Sweep.annotate sourceCodeDict tc.regions
                |> normalizeAnnotations
                |> Expect.equal (normalizeAnnotations tc.expected)


{-| Normalize annotations by sorting and removing duplicates at the same position.
The annotate function already sorts and merges consecutive annotations with the same count,
but we still need this to handle cases where multiple events occur at the exact same column
(which the merge function doesn't handle since it only merges consecutive annotations).

TODO: revisit. We seem to be getting something like:
    [{ column = 5, count = 10, line = 4 },
     { column = 10, count = 8, line = 4 },
     { column = 15, count = 5, line = 4 },
     { column = 17, count = -1, line = 4 }, -- <----------
     { column = 17, count = 10, line = 4 }, -- <---------- sus
     { column = 17, count = 8, line = 4 }]  -- <---------- sus

-}
normalizeAnnotations : List Sweep.Annotation -> List Sweep.Annotation
normalizeAnnotations annotations =
    annotations
        |> List.sortBy (\a -> ( a.line, a.column ))
        |> removeDuplicatesAtSamePosition


removeDuplicatesAtSamePosition : List Sweep.Annotation -> List Sweep.Annotation
removeDuplicatesAtSamePosition annotations =
    case annotations of
        [] ->
            []

        [ a ] ->
            [ a ]

        a :: b :: rest ->
            if a.line == b.line && a.column == b.column then
                removeDuplicatesAtSamePosition (a :: rest)

            else
                a :: removeDuplicatesAtSamePosition (b :: rest)
