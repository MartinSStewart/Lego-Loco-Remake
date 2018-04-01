module Model exposing (..)

import Int2 exposing (Int2)
import Mouse exposing (Position)
import Toolbox exposing (Toolbox)
import List.Extra
import Tiles exposing (..)


type alias Model =
    { viewPosition : Int2 -- Position of view in pixel coordinates.
    , viewSize : Int2 -- Size of view in pixel coordinates.
    , tileInstances : List Tile
    , toolbox : Toolbox
    , currentTile : Maybe Int2
    , currentRotation : Int
    , lastTilePosition : Maybe Int2
    , mousePosCurrent : Mouse.Position
    , windowSize : Int2
    }


type alias Tile =
    { tileId : Int
    , position : Int2
    , rotationIndex : Int
    }


modelSetToolbox : Model -> Toolbox -> Model
modelSetToolbox model toolbox =
    { model | toolbox = toolbox }


setToolbox : { b | toolbox : a } -> c -> { b | toolbox : c }
setToolbox model toolbox =
    { model | toolbox = toolbox }


modelSetToolboxViewPosition : Model -> Int2 -> Model
modelSetToolboxViewPosition model viewPosition =
    Toolbox.setViewPosition viewPosition model.toolbox |> modelSetToolbox model


modelSetViewPosition : Int2 -> Model -> Model
modelSetViewPosition viewPosition model =
    { model | viewPosition = viewPosition }


setCurrentTile : Maybe Int2 -> Model -> Model
setCurrentTile currentTile model =
    { model | currentTile = currentTile }


modelAddTile : Tile -> Model -> Model
modelAddTile tileInstance model =
    let
        newTileInstances =
            List.filter (\a -> not (collidesWith a tileInstance)) model.tileInstances ++ [ tileInstance ]
    in
        { model | tileInstances = newTileInstances }


setLastTilePosition : Maybe Int2 -> Model -> Model
setLastTilePosition lastTilePosition model =
    { model | lastTilePosition = lastTilePosition }


setMousePosCurrent : Position -> Model -> Model
setMousePosCurrent position model =
    { model | mousePosCurrent = position }


collidesWith : Tile -> Tile -> Bool
collidesWith tileInstance0 tileInstance1 =
    let
        getTileSize tileInstance =
            getTileOrDefault tileInstance.tileId |> .gridSize
    in
        Int2.rectangleCollision
            tileInstance0.position
            (getTileSize tileInstance0)
            tileInstance1.position
            (getTileSize tileInstance1)


collisionsAt : Model -> Int2 -> Int2 -> List Tile
collisionsAt model gridPosition gridSize =
    let
        getTileSize tileInstance =
            getTileOrDefault tileInstance.tileId |> .gridSize
    in
        List.filter
            (\a -> Int2.rectangleCollision a.position (getTileSize a) gridPosition gridSize)
            model.tileInstances


getTileOrDefault : Int -> TileType
getTileOrDefault tileId =
    case List.Extra.getAt tileId tiles of
        Just tile ->
            tile

        Nothing ->
            defaultTile


getTileByTileInstance : Tile -> TileType
getTileByTileInstance tileInstance =
    case List.Extra.getAt tileInstance.tileId tiles of
        Just tile ->
            tile

        Nothing ->
            defaultTile
