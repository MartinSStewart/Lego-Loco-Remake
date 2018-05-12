module Tile exposing (..)

import Point2 exposing (Point2)
import TileType exposing (tiles)
import List.Extra
import Model exposing (..)
import Lenses
import Monocle.Lens as Lens
import Helpers exposing (ifThenElse)


initTile : TileBaseData -> Tile
initTile tileBaseData =
    Tile
        tileBaseData
        (getTileOrDefault tileBaseData.tileId |> .data |> initTileData)


initTileData : Model.TileTypeData -> Model.TileData
initTileData tileTypeData =
    case tileTypeData of
        Basic _ ->
            TileBasic

        Rail _ _ ->
            TileRail []

        RailFork _ _ _ ->
            TileRailFork [] False

        Model.Depot _ ->
            TileDepot [] True


gridToPixels : Int
gridToPixels =
    16


pixelsToGrid : Float
pixelsToGrid =
    1 / (toFloat gridToPixels)


viewToGrid : Point2 Int -> Model -> Point2 Int
viewToGrid viewPoint model =
    viewPoint
        |> Point2.add model.viewPosition
        |> Point2.toFloat
        |> Point2.rmultScalar pixelsToGrid
        |> Point2.floor


viewToTileGrid : Point2 Int -> Model -> Model.TileTypeId -> Point2 Int
viewToTileGrid viewPoint model tileTypeId =
    tileTypeGridSize model.currentRotation (getTileOrDefault tileTypeId)
        |> Point2.rdiv 2
        |> Point2.sub (viewToGrid viewPoint model)


{-| Gets the size of the tile when accounting for rotation.
-}
tileGridSize : TileBaseData -> Point2 Int
tileGridSize tileBaseData =
    let
        (Model.TileTypeId id) =
            tileBaseData.tileId

        size =
            case List.Extra.getAt id tiles of
                Just tileType ->
                    tileType.gridSize

                Nothing ->
                    Debug.crash "This should never happen" Point2.one
    in
        if tileBaseData.rotationIndex % 2 == 0 then
            size
        else
            Point2.transpose size


tileTypeGridSize : Int -> Model.TileType -> Point2 Int
tileTypeGridSize rotation tileType =
    if rotation % 2 == 0 then
        tileType.gridSize
    else
        Point2.transpose tileType.gridSize


addTile : Tile -> Model -> Model
addTile tile model =
    Lens.modify
        Lenses.tiles
        (List.filter (.baseData >> collidesWith tile.baseData >> not) >> (::) tile)
        model


removeTile : TileBaseData -> Model -> Model
removeTile baseData model =
    model |> Lens.modify Lenses.tiles (List.filter (.baseData >> (/=) baseData))


modifyTile : Tile -> Model -> Model
modifyTile tile model =
    Lens.modify
        Lenses.tiles
        (List.map (\a -> ifThenElse (a.baseData == tile.baseData) tile a))
        model


clickTile : TileBaseData -> Model -> Model
clickTile tileBaseData model =
    Lens.modify
        Lenses.tiles
        (List.map
            (\a ->
                if (a.baseData == tileBaseData) then
                    Lens.modify Lenses.data
                        (\data ->
                            case data of
                                TileBasic ->
                                    data

                                TileRail _ ->
                                    data

                                TileRailFork trains isOn ->
                                    TileRailFork trains (not isOn)

                                TileDepot trains occupied ->
                                    TileDepot (ifThenElse occupied (Train 0 0 :: trains) trains) False
                        )
                        a
                else
                    a
            )
        )
        model


collidesWith : TileBaseData -> TileBaseData -> Bool
collidesWith tileBase0 tileBase1 =
    Point2.rectangleCollision
        tileBase0.position
        (tileGridSize tileBase0)
        tileBase1.position
        (tileGridSize tileBase1)


collisionsAt : Point2 Int -> Point2 Int -> Model -> List Tile
collisionsAt gridPosition gridSize model =
    List.filter
        (\a ->
            Point2.rectangleCollision
                a.baseData.position
                (tileGridSize a.baseData)
                gridPosition
                gridSize
        )
        model.tiles


getTileOrDefault : Model.TileTypeId -> TileType
getTileOrDefault tileTypeId =
    let
        (Model.TileTypeId id) =
            tileTypeId
    in
        case List.Extra.getAt id TileType.tiles of
            Just tile ->
                tile

            Nothing ->
                Debug.crash "Nonexistant tile id used." TileType.sidewalk


getTileTypeByTile : TileBaseData -> TileType
getTileTypeByTile tileBaseData =
    let
        (Model.TileTypeId id) =
            tileBaseData.tileId
    in
        case List.Extra.getAt id TileType.tiles of
            Just tile ->
                tile

            Nothing ->
                TileType.sidewalk
