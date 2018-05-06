module Tile exposing (..)

import Point2 exposing (Point2)
import TileType exposing (tiles)
import List.Extra
import Model exposing (Tile)


{-| Gets the size of the tile when accounting for rotation.
-}
gridSize : Tile -> Point2 Int
gridSize tile =
    let
        (Model.TileTypeId id) =
            tile.tileId

        size =
            case List.Extra.getAt id tiles of
                Just tileType ->
                    tileType.gridSize

                Nothing ->
                    Debug.crash "This should never happen" Point2.one
    in
        if tile.rotationIndex % 2 == 0 then
            size
        else
            Point2.transpose size


tileTypeGridSize : Int -> Model.TileType -> Point2 Int
tileTypeGridSize rotation tileType =
    if rotation % 2 == 0 then
        tileType.gridSize
    else
        Point2.transpose tileType.gridSize
