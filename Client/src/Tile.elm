module Tile exposing (..)

import Helpers exposing (ifThenElse)
import List.Extra
import Model exposing (..)
import Point2 exposing (Point2)
import TileType exposing (tiles)
import Html exposing (Html)
import SpriteHelper


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


worldToGrid : Point2 Int -> Point2 Int
worldToGrid worldPosition =
    Point2.div worldPosition gridToPixels


{-| viewPoint is a point in view coordinates.
viewPosition is the position of the camera in world coordinates.
The returned point is in grid coordinates.
-}
viewToGrid : Point2 Int -> Point2 Int -> Point2 Int
viewToGrid viewPoint viewPosition =
    viewPoint
        |> Point2.add viewPosition
        |> Point2.toFloat
        |> Point2.rmultScalar pixelsToGrid
        |> Point2.floor


viewToTileGrid : Point2 Int -> Model -> Model.TileTypeId -> Point2 Int
viewToTileGrid viewPoint model tileTypeId =
    tileTypeGridSize model.currentRotation (getTileOrDefault tileTypeId)
        |> Point2.rdiv 2
        |> Point2.sub (viewToGrid viewPoint model.viewPosition)


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


collidesWith : TileBaseData -> TileBaseData -> Bool
collidesWith tileBase0 tileBase1 =
    Point2.rectangleCollision
        tileBase0.position
        (tileGridSize tileBase0)
        tileBase1.position
        (tileGridSize tileBase1)


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


tileView : Tile -> Bool -> Int -> Html msg
tileView tile seeThrough zIndex =
    let
        tileType =
            getTileTypeByTile tile.baseData

        getSprite rotSprite =
            Helpers.rotGetAt rotSprite tile.baseData.rotationIndex

        tileDataAssert expected tile sprite =
            Debug.crash
                (expected
                    ++ " data was expected. Got "
                    ++ toString tile.data
                    ++ " instead."
                )
                sprite

        ( clickable, tileSprite ) =
            case tileType.data of
                Basic rotSprite ->
                    let
                        sprite =
                            getSprite rotSprite
                    in
                        case tile.data of
                            TileBasic ->
                                sprite |> (,) False

                            _ ->
                                tileDataAssert "TileBasic" tile sprite |> (,) False

                Rail rotSprite _ ->
                    let
                        sprite =
                            getSprite rotSprite
                    in
                        case tile.data of
                            TileRail _ ->
                                sprite |> (,) False

                            _ ->
                                tileDataAssert "TileRail" tile sprite |> (,) False

                RailFork rotSprite _ _ ->
                    let
                        ( spriteOn, spriteOff ) =
                            getSprite rotSprite
                    in
                        case tile.data of
                            TileRailFork _ isOn ->
                                ifThenElse isOn spriteOn spriteOff |> (,) True

                            _ ->
                                tileDataAssert "TileRailFork" tile spriteOff |> (,) False

                Depot rotSprite ->
                    let
                        ( spriteOccupied, spriteOpen, spriteClosed ) =
                            getSprite rotSprite
                    in
                        case tile.data of
                            TileDepot _ isOn ->
                                spriteOccupied |> (,) True

                            _ ->
                                tileDataAssert "TileDepot" tile spriteOccupied |> (,) False

        pos =
            Point2.multScalar tile.baseData.position gridToPixels

        size =
            tileType.gridSize
                |> Point2.mult (Point2 gridToPixels gridToPixels)

        styleTuples =
            [ ( "z-index", toString zIndex ), ( "pointer-events", "none" ) ]
                ++ ifThenElse seeThrough [ ( "opacity", "0.5" ) ] []
    in
        SpriteHelper.spriteViewWithStyle pos tileSprite styleTuples
