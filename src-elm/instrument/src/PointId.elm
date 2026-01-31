module PointId exposing (PointId, generator)

import Random exposing (Generator)

type alias PointId =
    Int

generator : Generator PointId
generator =
    Random.int 0 Random.maxInt