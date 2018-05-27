module Tile exposing (..)

import Helpers exposing (ifThenElse)
import List.Extra
import Model exposing (..)
import Point2 exposing (Point2)
import TileType exposing (tiles)
import Html exposing (Html)
import SpriteHelper
import Rectangle
import Html exposing (div)
import Sprite


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

        Model.Depot _ _ ->
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


viewToTileGrid : Point2 Int -> Point2 Int -> Int -> Model.TileTypeId -> Point2 Int
viewToTileGrid viewPoint viewPosition tileRotation tileTypeId =
    tileTypeGridSize tileRotation (getTileOrDefault tileTypeId)
        |> Point2.rdiv 2
        |> Point2.sub (viewToGrid viewPoint viewPosition)


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
    Rectangle.overlap
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


tileDataWithoutTrains : TileData -> TileData
tileDataWithoutTrains tileData =
    case tileData of
        TileBasic ->
            tileData

        TileRail trainList ->
            TileRail []

        TileRailFork trainList bool ->
            TileRailFork [] bool

        TileDepot trainList bool ->
            TileDepot [] bool


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

                Depot rotSprite _ ->
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
        div [] [ SpriteHelper.spriteViewWithStyle pos tileSprite styleTuples, tileTrainView tile (zIndex + 1) ]


tileTrainView : Tile -> Int -> Html msg
tileTrainView tile zIndex =
    let
        tileType =
            getTileTypeByTile tile.baseData

        styleTuples =
            [ ( "z-index", toString zIndex ), ( "pointer-events", "none" ) ]

        trainDiv pos path train =
            SpriteHelper.spriteViewWithStyle
                (train.t
                    --|> path
                    |> (pathToGridPath tile path)
                    --|> Point2.add (Point2.toFloat pos)
                    |> Point2.rmultScalar (toFloat gridToPixels)
                    |> Point2.floor
                )
                Sprite.sidewalk
                styleTuples
    in
        case tileType.data of
            Basic _ ->
                div [] []

            Rail _ path ->
                case tile.data of
                    TileRail trains ->
                        trains |> List.map (trainDiv tile.baseData.position path) |> div []

                    _ ->
                        div [] []

            RailFork _ pathOn pathOff ->
                case tile.data of
                    TileRailFork trains isOn ->
                        trains
                            |> List.map (trainDiv tile.baseData.position (ifThenElse isOn pathOn pathOff))
                            |> div []

                    _ ->
                        div [] []

            Depot _ path ->
                case tile.data of
                    TileDepot trains isOccupied ->
                        trains |> List.map (trainDiv tile.baseData.position path) |> div []

                    _ ->
                        div [] []


pathToGridPath : Tile -> (Float -> Point2 Float) -> (Float -> Point2 Float)
pathToGridPath tile path =
    let
        halfSize =
            getTileTypeByTile tile.baseData
                |> .gridSize
                |> Point2.toFloat
                |> Point2.rmultScalar 0.5

        halfSizeRotated =
            tileGridSize tile.baseData
                |> Point2.toFloat
                |> Point2.rmultScalar 0.5

        tilePos =
            tile.baseData.position |> Point2.toFloat
    in
        (path
            >> Point2.rsub halfSize
            >> Point2.rotateBy90 tile.baseData.rotationIndex
            >> Point2.add halfSizeRotated
            >> Point2.add tilePos
        )
