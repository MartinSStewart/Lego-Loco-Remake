module Tests exposing (..)

import Expect
import Fuzz exposing (int, list)
import Grid exposing (addTile)
import Main
import Model exposing (TileBaseData)
import Point2 exposing (..)
import Rectangle
import Set
import Test exposing (..)
import Tile exposing (collidesWith)
import TileType exposing (..)
import TestHelper
import Config


-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!


all : Test
all =
    describe "A Test Suite"
        [ test "Tiles right on top of eachother should collide." <|
            \_ ->
                collidesWith
                    (TileBaseData redHouseId Point2.zero 0)
                    (TileBaseData sidewalkId Point2.zero 0)
                    |> Expect.equal True
        , test "Tiles next to eachother should not collide." <|
            \_ ->
                collidesWith
                    (TileBaseData redHouseId Point2.zero 0)
                    (TileBaseData sidewalkId (Point2 3 0) 0)
                    |> Expect.equal False
        , test "Tiles overlapping should collide." <|
            \_ ->
                collidesWith
                    (TileBaseData redHouseId Point2.zero 0)
                    (TileBaseData redHouseId (Point2 2 -2) 0)
                    |> Expect.equal True
        , test "Rectangles next to eachother should not collide." <|
            \_ ->
                Rectangle.overlap Point2.zero (Point2 3 3) (Point2 3 0) (Point2 3 3)
                    |> Expect.equal False
        , test "Point outside rectangle." <|
            \_ ->
                Point2.inRectangle Point2.zero (Point2 3 3) (Point2 3 0)
                    |> Expect.equal False
        , test "Point inside rectangle." <|
            \_ ->
                Point2.inRectangle Point2.zero (Point2 3 3) (Point2 2 0)
                    |> Expect.equal True
        , test "Placing a house to the right of a sidewalk tile does not remove the sidewalk." <|
            \_ ->
                Grid.init
                    |> addTile (TileBaseData sidewalkId Point2.zero 0 |> Tile.initTile)
                    |> addTile (TileBaseData redHouseId (Point2 1 0) 0 |> Tile.initTile)
                    |> Grid.tileCount
                    |> Expect.equal 2
        , fuzz (list TestHelper.fuzzTile) "Add and remove tiles" <|
            \a ->
                let
                    tiles =
                        a |> List.map TestHelper.fuzzTileToTile

                    grid =
                        tiles |> List.foldl Grid.addTile Grid.init
                in
                    tiles
                        |> List.foldl (\a b -> Grid.removeTile a.baseData b) grid
                        |> Grid.tileCount
                        |> Expect.equal 0
        , test "Window resize updates pending get regions." <|
            \a ->
                Main.initModel
                    |> Main.update (Main.WindowResize { width = 1000, height = 1000 })
                    |> Tuple.first
                    |> .pendingGetRegions
                    |> Set.size
                    |> Expect.greaterThan 0
        , test "viewToTileGrid negative value" <|
            \_ ->
                Tile.viewToTileGrid Point2.zero (Point2 (-Config.superGridSize * 2) -Config.superGridSize) 0 TileType.sidewalkId |> Expect.equal (Point2 -2 -1)
        , test "viewToTileGrid positive value" <|
            \_ ->
                Tile.viewToTileGrid Point2.zero (Point2 (Config.superGridSize * 2) Config.superGridSize) 0 TileType.sidewalkId |> Expect.equal (Point2 2 1)
        ]
