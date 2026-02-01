module Main exposing (main)

import Platform

main : Program () () ()
main =
    Platform.worker
        { init = \() -> ((), Cmd.none)
        , update = \_ _ -> ((), Cmd.none)
        , subscriptions = \_ -> Sub.none
        }
