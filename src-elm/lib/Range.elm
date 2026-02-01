module Range exposing (Position, Range, decodePosition, decodeRange, encodePosition, encodeRange)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode


type alias Position =
    { row : Int
    , column : Int
    }


type alias Range =
    { start : Position
    , end : Position
    }


encodePosition : Position -> Json.Encode.Value
encodePosition position =
    Json.Encode.list Json.Encode.int
        [ position.row
        , position.column
        ]


decodePosition : Decoder Position
decodePosition =
    Decode.map2 Position
        (Decode.index 0 Decode.int)
        (Decode.index 1 Decode.int)


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


decodeRange : Decoder Range
decodeRange =
    Decode.map2 Range
        (Decode.index 0 decodePosition)
        (Decode.index 1 decodePosition)
