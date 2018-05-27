module Grid exposing (..)

import Config
import Dict
import Helpers exposing (ifThenElse)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Lenses
import List.FlatMap
import Model exposing (..)
import Monocle.Lens as Lens exposing (Lens)
import Point2 exposing (Point2)
import Rectangle exposing (Rectangle)
import Tile


init : Grid
init =
    Dict.empty


gridPosToSuperPos : Point2 Int -> Point2 Int
gridPosToSuperPos gridPosition =
    Point2
        (gridPosition.x // Config.superGridSize - (ifThenElse (gridPosition.x < 0) 1 0))
        (gridPosition.y // Config.superGridSize - (ifThenElse (gridPosition.y < 0) 1 0))


getSetAt : Point2 Int -> Lens Grid (List Tile)
getSetAt superPosition =
    let
        key =
            ( superPosition.x, superPosition.y )
    in
        Lens
            (Dict.get key >> Maybe.withDefault [])
            (Dict.insert key)


neighborPoints : Point2 Int -> List (Point2 Int)
neighborPoints point =
    List.range 0 8 |> List.map (Point2.intToInt2 3 >> Point2.add point >> Point2.rsub Point2.one)


addTile : Tile -> Grid -> Grid
addTile tile grid =
    let
        superPosition =
            gridPosToSuperPos tile.baseData.position
    in
        neighborPoints superPosition
            |> List.filter (\a -> Dict.get (Point2.toTuple a) grid |> (/=) Nothing)
            |> List.foldl
                (\superPos a ->
                    Lens.modify
                        (getSetAt superPos)
                        (List.filter (.baseData >> Tile.collidesWith tile.baseData >> not))
                        a
                )
                grid
            |> Lens.modify (getSetAt superPosition) ((::) tile)


tileInSuperGridPos : Point2 Int -> Tile -> Bool
tileInSuperGridPos superGridPosition tile =
    tile.baseData.position
        |> gridPosToSuperPos
        |> (==) superGridPosition


loadTiles : Point2 Int -> List Tile -> Grid -> Grid
loadTiles superGridPosition tiles grid =
    let
        tilesInCorrectSuperPos =
            List.all
                (tileInSuperGridPos superGridPosition)
                tiles

        _ =
            if tilesInCorrectSuperPos then
                ()
            else
                Debug.crash
                    ("Tiles loaded must be in correct super grid."
                        ++ toString superGridPosition
                        ++ toString tiles
                    )
                    ()
    in
        .set (getSetAt superGridPosition) tiles grid


loadTrains : Point2 Int -> List Tile -> Grid -> Grid
loadTrains superGridPosition trainTiles grid =
    let
        tilesInCorrectSuperPos =
            List.all
                (tileInSuperGridPos superGridPosition)
                trainTiles

        _ =
            if tilesInCorrectSuperPos then
                ()
            else
                Debug.crash
                    ("Tiles loaded must be in correct super grid."
                        ++ toString superGridPosition
                        ++ toString trainTiles
                    )
                    ()

        tileKey =
            .baseData >> .position >> Point2.toTuple

        trainTileDict =
            trainTiles
                |> List.map (\a -> ( tileKey a, a ))
                |> Dict.fromList
    in
        Lens.modify
            (getSetAt superGridPosition)
            (List.map
                (\tile ->
                    Lens.modify
                        Lenses.data
                        (\tileData ->
                            Dict.get (tileKey tile) trainTileDict
                                |> Maybe.map .data
                                |> Maybe.withDefault (Tile.tileDataWithoutTrains tileData)
                        )
                        tile
                )
            )
            grid


update : Rectangle Int -> Grid -> ( Grid, List (Point2 Int) )
update viewRegion grid =
    let
        keyToWorldPos key =
            Point2 (Tuple.first key) (Tuple.second key)
                |> Point2.rmultScalar (Config.superGridSize * Tile.gridToPixels)

        superWorldSize =
            Point2.multScalar Point2.one (Config.superGridSize * Tile.gridToPixels)

        newGrid =
            Dict.filter
                (\k _ -> Point2.fromTuple k |> insideView viewRegion)
                grid

        superPosition =
            viewRegion.topLeft |> Tile.worldToGrid |> gridPosToSuperPos

        superSize =
            viewRegion.size
                |> Tile.worldToGrid
                |> gridPosToSuperPos
                |> Point2.add (Point2 2 2)

        needsUpdate =
            List.range 0 (Point2.area superSize - 1)
                |> List.map (Point2.intToInt2 superSize.x >> Point2.add superPosition)
                |> List.filter (\a -> Dict.get ( a.x, a.y ) grid |> (==) Nothing)
    in
        ( newGrid, needsUpdate )


insideView : Rectangle Int -> Point2 Int -> Bool
insideView viewRegion superPos =
    let
        viewSuperPos =
            viewRegion.topLeft |> Tile.worldToGrid |> gridPosToSuperPos

        viewSuperSize =
            viewRegion.size
                |> Tile.worldToGrid
                |> gridPosToSuperPos
                |> Point2.add (Point2 2 2)
    in
        Point2.inRectangle viewSuperPos viewSuperSize superPos


clearRegion : Point2 Int -> Grid -> Grid
clearRegion superPos grid =
    Dict.remove (Point2.toTuple superPos) grid


view : Int -> Rectangle Int -> Grid -> Html msg
view minZIndex viewRegion grid =
    let
        keyToWorldPos key =
            Point2 (Tuple.first key) (Tuple.second key)
                |> Point2.rmultScalar (Config.superGridSize * Tile.gridToPixels)

        superWorldSize =
            Point2.multScalar Point2.one (Config.superGridSize * Tile.gridToPixels)

        superTiles =
            grid
                |> Dict.filter (\k _ -> True)
                --Point2.fromTuple k |> insideView viewRegion)
                |> Dict.values
                |> List.FlatMap.flatMap (\a -> a)
                |> List.map (\a -> Tile.tileView a False (minZIndex + a.baseData.position.y))
    in
        -- The view offset is applied to a parent div to minimize the amount of virtual dom changes when the view moves.
        div [ style <| ( "pointer-events", "none" ) :: Helpers.absoluteStyle (Point2.negate viewRegion.topLeft) viewRegion.size ]
            superTiles


removeTile : TileBaseData -> Grid -> Grid
removeTile baseData superGrid =
    Lens.modify
        (gridPosToSuperPos baseData.position |> getSetAt)
        (List.filter (.baseData >> (/=) baseData))
        superGrid


clickTile : TileBaseData -> Grid -> Grid
clickTile tileBaseData superGrid =
    Lens.modify
        (gridPosToSuperPos tileBaseData.position |> getSetAt)
        (List.map
            (\a ->
                if (a.baseData == tileBaseData) then
                    Lens.modify Lenses.data
                        (\data ->
                            case data of
                                Model.TileBasic ->
                                    data

                                Model.TileRail _ ->
                                    data

                                Model.TileRailFork trains isOn ->
                                    Model.TileRailFork trains (not isOn)

                                Model.TileDepot trains occupied ->
                                    Model.TileDepot
                                        (ifThenElse occupied (Model.Train 0 0 True (TrainId 0) :: trains) trains)
                                        False
                        )
                        a
                else
                    a
            )
        )
        superGrid


modifyTileData : TileBaseData -> (TileData -> TileData) -> Grid -> Grid
modifyTileData tileBaseData modify grid =
    let
        superPos =
            gridPosToSuperPos tileBaseData.position
    in
        Lens.modify (getSetAt superPos)
            (\tiles ->
                List.map
                    (\tile ->
                        if tile.baseData == tileBaseData then
                            { tile | data = modify tile.data }
                        else
                            tile
                    )
                    tiles
            )
            grid


getTrainTiles : Grid -> List Tile
getTrainTiles grid =
    Dict.toList grid
        |> List.FlatMap.flatMap (\( key, value ) -> value)
        |> List.filter
            (\a ->
                case a.data of
                    TileBasic ->
                        False

                    TileRail trains ->
                        List.length trains > 0

                    TileRailFork trains _ ->
                        List.length trains > 0

                    TileDepot trains _ ->
                        List.length trains > 0
            )


tileCount : Grid -> Int
tileCount grid =
    Dict.values grid |> List.FlatMap.flatMap (\a -> a) |> List.length


collisionsAt : Point2 Int -> Point2 Int -> Grid -> List Tile
collisionsAt gridPosition gridSize grid =
    let
        assert =
            if gridSize.x > Config.superGridSize || gridSize.y > Config.superGridSize then
                Debug.crash "Grid size is too large."
            else
                ""
    in
        neighborPoints (gridPosToSuperPos gridPosition)
            |> List.map (\a -> .get (getSetAt a) grid)
            |> List.FlatMap.flatMap (\a -> a)
            |> List.filter
                (\tile ->
                    Rectangle.overlap
                        gridPosition
                        gridSize
                        tile.baseData.position
                        (Tile.tileGridSize tile.baseData)
                )
