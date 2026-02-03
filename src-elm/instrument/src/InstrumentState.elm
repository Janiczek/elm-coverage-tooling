module InstrumentState exposing (InstrumentState, init)

import Elm.Syntax.Declaration exposing (Declaration)
import Elm.Syntax.Node exposing (Node)
import FNV1a
import PointId exposing (PointId)
import PointMetadata exposing (PointMetadata)
import Random exposing (Seed)


type alias InstrumentState =
    { newDeclarations : List (Node Declaration)
    , metadataList : List ( PointId, PointMetadata )
    , seed : Random.Seed
    , moduleName : String
    , moduleFilePath : String
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

        moduleFilePath : String
        moduleFilePath =
            (moduleName |> String.split "." |> String.join "/") ++ ".elm"
    in
    { newDeclarations = []
    , metadataList = []
    , seed = randomSeed
    , moduleName = moduleName
    , moduleFilePath = moduleFilePath
    }
