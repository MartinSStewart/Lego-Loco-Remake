module Grid exposing (addTile, removeTile, clickTile, collisionsAt, init, tileCount, clearRegion, loadTiles, view, update)

import Config
import Dict
import Helpers exposing (ifThenElse)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Lenses
import List.Extra
import List.FlatMap
import Model exposing (Grid, Tile, TileBaseData)
import Monocle.Lens as Lens exposing (Lens)
import Point2 exposing (Point2)
import Rectangle exposing (Rectangle)
import Tile


init : Grid
init =
    Dict.empty


gridPosToSuperPos : Point2 Int -> Point2 Int
gridPosToSuperPos gridPosition =
    Point2.div gridPosition Config.superGridSize


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
    List.range 0 8 |> List.map (Point2.intToInt2 3 >> Point2.add point)


addTile : Tile -> Grid -> Grid
addTile tile grid =
    let
        superPosition =
            gridPosToSuperPos tile.baseData.position
    in
        neighborPoints superPosition
            |> List.foldl
                (\superPos a ->
                    Lens.modify
                        (getSetAt superPos)
                        (List.filter (.baseData >> Tile.collidesWith tile.baseData >> not))
                        a
                )
                grid
            |> Lens.modify (getSetAt superPosition) ((::) tile)


loadTiles : List Tile -> Grid -> Grid
loadTiles tiles grid =
    let
        tilePos tile =
            tile.baseData.position
    in
        tiles
            |> List.Extra.groupWhile (\a b -> gridPosToSuperPos (tilePos a) == gridPosToSuperPos (tilePos b))
            |> List.foldl
                (\a b ->
                    let
                        superPos =
                            a
                                |> List.head
                                |> Maybe.map (tilePos >> gridPosToSuperPos)
                                |> Maybe.withDefault Point2.zero
                    in
                        .set (getSetAt superPos) a b
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


clearRegion : Point2 Int -> Point2 Int -> Grid -> Grid
clearRegion superPos superSize grid =
    Dict.filter (\( x, y ) _ -> Point2.inRectangle superPos superSize (Point2 x y) |> not) grid


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
                                    Model.TileDepot (ifThenElse occupied (Model.Train 0 0 :: trains) trains) False
                        )
                        a
                else
                    a
            )
        )
        superGrid


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
