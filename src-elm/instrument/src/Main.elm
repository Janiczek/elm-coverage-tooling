module Main exposing (Input, Output, main, work)

import Dict exposing (Dict)
import Elm.Parser
import Elm.Syntax.Declaration exposing (Declaration)
import Elm.Syntax.Expression
import Elm.Syntax.File exposing (File)
import Elm.Syntax.Module
import Elm.Syntax.Node exposing (Node(..))
import Elm.Syntax.Pattern
import Elm.Syntax.Signature
import Elm.Syntax.Type
import Elm.Syntax.TypeAlias
import ElmSyntaxPrint
import FNV1a
import Instrument
import InstrumentState exposing (InstrumentState)
import Json.Encode
import PointId exposing (PointId)
import PointMetadata exposing (PointMetadata)
import PureFunction exposing (PureMain)
import Random exposing (Generator)


type alias Input =
    { elmSourceCode : String }


type alias Output =
    Result String SuccessOutput


type alias SuccessOutput =
    { instrumentedElmSourceCode : String
    , coverageMetadata : Dict PointId PointMetadata
    , contentHash : Int
    }


main : PureMain Input
main =
    PureFunction.pureFunction
        { work = work
        , encodeOutput = encodeOutput
        }


encodeOutput : Output -> Json.Encode.Value
encodeOutput output =
    case output of
        Err err ->
            Json.Encode.object
                [ ( "error", Json.Encode.string err )
                ]

        Ok success ->
            Json.Encode.object
                [ ( "instrumentedElmSourceCode", Json.Encode.string success.instrumentedElmSourceCode )
                , ( "coverageMetadata"
                  , Json.Encode.dict
                        String.fromInt
                        PointMetadata.encode
                        success.coverageMetadata
                  )
                , ( "contentHash"
                  , Json.Encode.int success.contentHash
                  )
                ]


work : Input -> Output
work { elmSourceCode } =
    case Elm.Parser.parseToFile elmSourceCode of
        Err _ ->
            -- TODO: more details?
            Err "Can't parse the Elm code."

        Ok file ->
            let
                ( instrumentedElmAST, coverageMetadata ) =
                    Instrument.instrument file
            in
            Ok
                { instrumentedElmSourceCode = format instrumentedElmAST
                , coverageMetadata = coverageMetadata
                , contentHash = FNV1a.hash elmSourceCode
                }


format : File -> String
format file =
    file
        |> ElmSyntaxPrint.module_
        |> ElmSyntaxPrint.toString
