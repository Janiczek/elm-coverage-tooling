module PointMetadata exposing (PointMetadata, decode, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode
import Range exposing (Range)


type alias PointMetadata =
    { moduleName : String
    , declarationName : String
    , range : Range
    }


encode : PointMetadata -> Json.Encode.Value
encode metadata =
    Json.Encode.object
        [ ( "moduleName", Json.Encode.string metadata.moduleName )
        , ( "declarationName", Json.Encode.string metadata.declarationName )
        , ( "range", Range.encodeRange metadata.range )
        ]


decode : Decoder PointMetadata
decode =
    Decode.map3 PointMetadata
        (Decode.field "moduleName" Decode.string)
        (Decode.field "declarationName" Decode.string)
        (Decode.field "range" Range.decodeRange)
