port module PureFunction exposing (pureFunction, PureMain)

import Json.Encode
import Platform

port sendOutput : Json.Encode.Value -> Cmd msg

type alias PureMain input = Program input () ()

{-| Creates a Platform.worker program for a pure function that takes input via flags
and sends output via a port.

Usage:

    module Main exposing (Flags, Input, Model, Msg, Output, main, work)

    import PureFunction

    type alias Input = { ... }
    type alias Output = Result String SuccessOutput

    type alias Flags = Input

    main : Program Flags Model Msg
    main =
        PureFunction.pureFunction
            { work = work
            , encodeOutput = encodeOutput
            }

    work : Input -> Output
    work input = ...

    encodeOutput : Output -> Json.Encode.Value
    encodeOutput output = ...
-}
pureFunction :
    { work : input -> output
    , encodeOutput : output -> Json.Encode.Value
    }
    -> PureMain input
pureFunction { work, encodeOutput } =
    Platform.worker
        { init = \flags -> ( (), flags |> work |> encodeOutput |> sendOutput )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
