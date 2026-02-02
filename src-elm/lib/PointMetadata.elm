module PointMetadata exposing (PointMetadata, decode, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode
import Range exposing (Range)


type alias PointMetadata =
    { moduleName : String
    , moduleFilePath : String
    , declarationName : String
    , range : Range
    , category : String
    }


encode : PointMetadata -> Json.Encode.Value
encode metadata =
    Json.Encode.object
        [ ( "moduleName", Json.Encode.string metadata.moduleName )
        , ( "moduleFilePath", Json.Encode.string metadata.moduleFilePath )
        , ( "declarationName", Json.Encode.string metadata.declarationName )
        , ( "range", Range.encodeRange metadata.range )
        , ( "category", Json.Encode.string metadata.category )
        ]


decode : Decoder PointMetadata
decode =
    Decode.map5 PointMetadata
        (Decode.field "moduleName" Decode.string)
        (Decode.field "moduleFilePath" Decode.string)
        (Decode.field "declarationName" Decode.string)
        (Decode.field "range" Range.decodeRange)
        (Decode.field "category" Decode.string)
