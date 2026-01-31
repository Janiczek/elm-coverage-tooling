port module Main exposing (Flags, Input, Model, Msg, PointMetadata, main)

import Dict exposing (Dict)
import Elm.Parser
import Elm.Syntax.File
import Elm.Syntax.Range exposing (Range)
import ElmSyntaxPrint
import Json.Encode


type alias Input =
    { elmSourceCode : String }


type alias Output =
    Result String SuccessOutput


type alias SuccessOutput =
    { instrumentedElmSourceCode : String
    , coverageMetadata : Dict Int PointMetadata
    }


type alias PointMetadata =
    { moduleName : String
    , declarationName : String
    , range : Range
    }


port sendOutput : Json.Encode.Value -> Cmd msg


type alias Flags =
    Input


type alias Model =
    ()


type alias Msg =
    Never


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = \_ m -> ( m, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


init : Flags -> ( Model, Cmd Msg )
init input =
    ( ()
    , input
        |> work
        |> encodeOutput
        |> sendOutput
    )


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
                        encodePointMetadata
                        success.coverageMetadata
                  )
                ]


encodePointMetadata : PointMetadata -> Json.Encode.Value
encodePointMetadata metadata =
    Json.Encode.object
        [ ( "moduleName", Json.Encode.string metadata.moduleName )
        , ( "declarationName", Json.Encode.string metadata.declarationName )
        , ( "range", encodeRange metadata.range )
        ]


encodeRange : Range -> Json.Encode.Value
encodeRange range =
    Json.Encode.list (Json.Encode.list Json.Encode.int)
        [ [ range.start.row
          , range.start.column
          ]
        , [ range.end.row
          , range.end.column
          ]
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
                    instrument file
            in
            Ok
                { instrumentedElmSourceCode = format instrumentedElmAST
                , coverageMetadata = coverageMetadata
                }


format : Elm.Syntax.File.File -> String
format file =
    file
        |> ElmSyntaxPrint.module_
        |> ElmSyntaxPrint.toString


instrument : Elm.Syntax.File.File -> ( Elm.Syntax.File.File, Dict Int PointMetadata )
instrument file =
    Debug.todo "instrument"
