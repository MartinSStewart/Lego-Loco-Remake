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
        size =
            case List.Extra.getAt tile.tileId tiles of
                Just tileType ->
                    tileType.gridSize

                Nothing ->
                    Debug.crash "This should never happen" Point2.one
    in
        if tile.rotationIndex % 2 == 0 then
            size
        else
            Point2.transpose size
