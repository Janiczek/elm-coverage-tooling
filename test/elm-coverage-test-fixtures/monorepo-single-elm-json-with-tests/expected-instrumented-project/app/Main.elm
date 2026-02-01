module Main exposing (main)

import Platform
import Test.Coverage


main : Program () () ()
main =
    let
        _ =
            Test.Coverage.track
                245304994
    in
    (let
        _ =
            Test.Coverage.track 1766750197
     in
     Platform.worker
    )
        (let
            _ =
                Test.Coverage.track
                    672707492
         in
         { init =
            let
                _ =
                    Test.Coverage.track 389929308
            in
            \() ->
                let
                    _ =
                        Test.Coverage.track 215408563
                in
                ( let
                    _ =
                        Test.Coverage.track 1225564788
                  in
                  (), let
                    _ =
                        Test.Coverage.track 440883689
                  in
                  Cmd.none )
         , update =
            let
                _ =
                    Test.Coverage.track 573104768
            in
            \_ _ ->
                let
                    _ =
                        Test.Coverage.track 559053829
                in
                ( let
                    _ =
                        Test.Coverage.track 474255985
                  in
                  (), let
                    _ =
                        Test.Coverage.track 2100962292
                  in
                  Cmd.none )
         , subscriptions =
            let
                _ =
                    Test.Coverage.track 1862290972
            in
            \_ ->
                let
                    _ =
                        Test.Coverage.track 2042476985
                in
                Sub.none
         }
        )
