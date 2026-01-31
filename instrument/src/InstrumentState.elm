module InstrumentState exposing (init, InstrumentState)


import Elm.Syntax.Node exposing (Node)
import Elm.Syntax.Declaration exposing (Declaration)
import Dict exposing (Dict)
import PointMetadata exposing (PointMetadata)
import Random exposing (Seed)
import PointId exposing (PointId)
import FNV1a

type alias InstrumentState =
    { newDeclarations : List (Node Declaration)
    , metadata : Dict PointId PointMetadata
    , seed : Random.Seed
    , moduleName : String
    }


init : String -> InstrumentState
init moduleName =
    let
        moduleHash : Int
        moduleHash =
            FNV1a.hash moduleName

        randomSeed : Random.Seed
        randomSeed =
            Random.initialSeed moduleHash
    in
    { newDeclarations = []
    , metadata = Dict.empty
    , seed = randomSeed
    , moduleName = moduleName
    }