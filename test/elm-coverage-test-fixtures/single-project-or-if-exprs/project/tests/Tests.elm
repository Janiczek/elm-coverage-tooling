module Tests exposing (suite)

import Expect
import OrIfExprs
import Test exposing (Test, test)

suite : Test
suite =
    Test.describe "OrIfExprs"
        [ test "fullCoverage: foo==1" <|
            \_ ->
                OrIfExprs.fullCoverage 1 0
                    |> Expect.equal ()
        , test "fullCoverage: bar==1" <|
            \_ ->
                OrIfExprs.fullCoverage 0 1
                    |> Expect.equal ()
        , test "fullCoverage: foo==2" <|
            \_ ->
                OrIfExprs.fullCoverage 2 0
                    |> Expect.equal ()
        , test "fullCoverage: bar==2" <|
            \_ ->
                OrIfExprs.fullCoverage 0 2
                    |> Expect.equal ()
        , test "fullCoverage: final else" <|
            \_ ->
                OrIfExprs.fullCoverage 0 0
                    |> Expect.equal ()
        , test "onlyFoo1: foo==1" <|
            \_ ->
                OrIfExprs.onlyFoo1 1 0
                    |> Expect.equal ()
        , test "onlyBar1: bar==1" <|
            \_ ->
                OrIfExprs.onlyBar1 0 1
                    |> Expect.equal ()
        , test "neitherFoo2: foo==2" <|
            \_ ->
                OrIfExprs.neitherFoo2 2 0
                    |> Expect.equal ()
        , test "neitherBar2: bar==2" <|
            \_ ->
                OrIfExprs.neitherBar2 0 2
                    |> Expect.equal ()
        , test "finalElse: final else" <|
            \_ ->
                OrIfExprs.finalElse 0 0
                    |> Expect.equal ()
        ]
