module Main exposing (main)

import Platform
import Test.Coverage


main : Program () () ()
main =
    Platform.worker
        { init =
            \() ->
                let
                    _ =
                        Test.Coverage.track 2100962292
                in
                ( let
                    _ =
                        Test.Coverage.track 474255985
                  in
                  ()
                , let
                    _ =
                        Test.Coverage.track 389929308
                  in
                  Cmd.none
                )
        , update =
            \_ _ ->
                let
                    _ =
                        Test.Coverage.track 215408563
                in
                ( let
                    _ =
                        Test.Coverage.track 440883689
                  in
                  ()
                , let
                    _ =
                        Test.Coverage.track 1225564788
                  in
                  Cmd.none
                )
        , subscriptions =
            \_ ->
                let
                    _ =
                        Test.Coverage.track 1766750197
                in
                Sub.none
        }
