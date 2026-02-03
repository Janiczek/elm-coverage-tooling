module Main exposing (main)

import Platform
import Test.Coverage


main : Program () () ()
main =
    let
        _ =
            Test.Coverage.track
                2100962292
    in
    Platform.worker
        { init =
            let
                _ =
                    Test.Coverage.track 1225564788
            in
            \() ->
                let
                    _ =
                        Test.Coverage.track 1766750197
                in
                ( (), Cmd.none )
        , update =
            let
                _ =
                    Test.Coverage.track 215408563
            in
            \_ _ ->
                let
                    _ =
                        Test.Coverage.track 440883689
                in
                ( (), Cmd.none )
        , subscriptions =
            let
                _ =
                    Test.Coverage.track 474255985
            in
            \_ ->
                let
                    _ =
                        Test.Coverage.track 389929308
                in
                Sub.none
        }
