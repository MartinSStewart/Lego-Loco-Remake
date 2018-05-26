module GridTests exposing (..)

import Expect
import Fuzz exposing (int, list)
import Helpers exposing (intMax, intMin)
import Test exposing (..)
import Grid
import Tile
import Model exposing (TileBaseData)
import TileType
import Point2 exposing (Point2)
import Config


all : Test
all =
    describe "Grid tests"
        [ test "Adding tile removes overlapping tile across grid seams." <|
            \_ ->
                let
                    addTile pos grid =
                        let
                            tile =
                                TileBaseData TileType.railTurnId pos 0 |> Tile.initTile
                        in
                            Grid.addTile tile grid
                in
                    Grid.init
                        |> addTile (Point2 (Config.superGridSize - 1) 0)
                        |> addTile (Point2 Config.superGridSize 0)
                        |> .get (Grid.getSetAt (Point2 0 0))
                        |> List.length
                        |> Expect.equal 0
        ]
