module Main exposing (Input, Output, main, work)

import Dict exposing (Dict)
import FNV1a
import Json.Decode as Decode exposing (Decoder)
import Json.Encode
import Platform
import PureFunction exposing (PureMain)
import Format exposing (Format(..), fromString)
import PointMetadata exposing (PointMetadata)
import Report exposing (Input, ReportFile)
import Report.Csv
import Report.Html
import Report.Lcov
import Report.Plaintext
import Report.Stdout


type alias Input =
    { coverageMetadata : Dict Int PointMetadata
    , coverageData : Dict Int Int
    , sources : Dict String String
    , moduleHashes : Dict String Int
    , format : String
    }


type alias Output =
    Result String SuccessOutput


type alias SuccessOutput =
    { reports : List ReportFile
    }


main : PureMain Json.Encode.Value
main =
    PureFunction.pureFunction
        { work =
            \flags ->
                case Decode.decodeValue flagsDecoder flags of
                    Ok input ->
                        work input

                    Err err ->
                        Err ("Failed to decode flags: " ++ Decode.errorToString err)
        , encodeOutput = encodeOutput
        }


flagsDecoder : Decoder Input
flagsDecoder =
    Decode.map5 Input
        (Decode.field "coverageMetadata" (dictIntKeysDecoder PointMetadata.decode))
        (Decode.field "coverageData" (dictIntKeysDecoder Decode.int))
        (Decode.field "sources" (Decode.dict Decode.string))
        (Decode.field "moduleHashes" (Decode.dict Decode.int))
        (Decode.field "format" Decode.string)


dictIntKeysDecoder : Decoder a -> Decoder (Dict Int a)
dictIntKeysDecoder valueDecoder =
    Decode.dict valueDecoder
        |> Decode.map
            (\dict ->
                Dict.toList dict
                    |> List.filterMap
                        (\( keyStr, value ) ->
                            String.toInt keyStr
                                |> Maybe.map (\keyInt -> ( keyInt, value ))
                        )
                    |> Dict.fromList
            )


work : Input -> Output
work input =
    let
        hashMismatches : List String
        hashMismatches =
            Dict.foldl
                (\moduleName sourceCode acc ->
                    case Dict.get moduleName input.moduleHashes of
                        Nothing ->
                            moduleName :: acc

                        Just expectedHash ->
                            let
                                actualHash : Int
                                actualHash =
                                    FNV1a.hash sourceCode
                            in
                            if actualHash == expectedHash then
                                acc

                            else
                                moduleName :: acc
                )
                []
                input.sources
    in
    if List.isEmpty hashMismatches then
        case fromString input.format of
            Just Html ->
                Ok (Report.Html.generate input)

            Just Stdout ->
                Ok (Report.Stdout.generate input)

            Just Plaintext ->
                Ok (Report.Plaintext.generate input)

            Just Lcov ->
                Ok (Report.Lcov.generate input)

            Just Csv ->
                Ok (Report.Csv.generate input)

            Nothing ->
                Err ("Unsupported format: " ++ input.format)

    else
        Err ("Content hash mismatch for modules: " ++ String.join ", " hashMismatches)


encodeOutput : Output -> Json.Encode.Value
encodeOutput output =
    case output of
        Err err ->
            Json.Encode.object
                [ ( "error", Json.Encode.string err )
                ]

        Ok success ->
            Json.Encode.object
                [ ( "reports"
                  , Json.Encode.list encodeReportFile success.reports
                  )
                ]


encodeReportFile : ReportFile -> Json.Encode.Value
encodeReportFile file =
    Json.Encode.object
        [ ( "filepath", Json.Encode.string file.filepath )
        , ( "contents", Json.Encode.string file.contents )
        ]
