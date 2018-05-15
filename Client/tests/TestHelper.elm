module TestHelper exposing (..)

import Fuzz exposing (int, list)
import Helpers exposing (intMax, intMin)
import Model exposing (TileBaseData)
import Point2 exposing (..)
import Tile exposing (collidesWith)
import TileType exposing (..)


fuzzTile : Fuzz.Fuzzer ( Int, Int, Int, Int )
fuzzTile =
    Fuzz.tuple4
        ( (List.length tiles - 1 |> Fuzz.intRange 0)
        , (Fuzz.intRange intMin intMax)
        , (Fuzz.intRange intMin intMax)
        , (Fuzz.intRange intMin intMax)
        )


fuzzTileToTile : ( Int, Int, Int, Int ) -> Model.Tile
fuzzTileToTile fuzzTile =
    let
        ( a, b, c, d ) =
            fuzzTile
    in
        TileBaseData
            (Model.TileTypeId a)
            (Point2 b c)
            d
            |> Tile.initTile
