module PointMetadata exposing (PointMetadata, encode)

import Elm.Syntax.Range exposing (Range)
import Json.Encode

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
