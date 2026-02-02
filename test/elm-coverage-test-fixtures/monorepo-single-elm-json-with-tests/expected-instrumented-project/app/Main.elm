module Main exposing (main)

import Platform
import Test.Coverage


main : Program () () ()
main =
    let
        _ =
            Test.Coverage.track
                215408563
    in
    Platform.worker
        { init =
            \() ->
                let
                    _ =
                        Test.Coverage.track 1766750197
                in
                ( (), Cmd.none )
        , update =
            \_ _ ->
                let
                    _ =
                        Test.Coverage.track 1225564788
                in
                ( (), Cmd.none )
        , subscriptions =
            \_ ->
                let
                    _ =
                        Test.Coverage.track 440883689
                in
                Sub.none
        }
