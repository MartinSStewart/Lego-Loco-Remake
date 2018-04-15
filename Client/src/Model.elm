module Model exposing (..)

import Int2 exposing (Int2)
import Mouse exposing (Position)
import Toolbox exposing (Toolbox)
import List.Extra
import TileType
import Lenses exposing (..)
import Monocle.Lens as Lens


type alias Model =
    { viewPosition : Int2 -- Position of view in pixel coordinates.
    , viewSize : Int2 -- Size of view in pixel coordinates.
    , tiles : List Tile
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


modelAddTile : Tile -> Model -> Model
modelAddTile tile model =
    model |> Lens.modify tiles (\a -> List.filter (\b -> not (collidesWith b tile)) a |> (::) tile)


setMousePosCurrent : Position -> ( Model, Cmd msg ) -> ( Model, Cmd msg )
setMousePosCurrent position modelCmd =
    ( mousePosCurrent.set position (Tuple.first modelCmd), Tuple.second modelCmd )


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
            model.tiles


getTileOrDefault : Int -> TileType.TileType
getTileOrDefault tileId =
    case List.Extra.getAt tileId TileType.tiles of
        Just tile ->
            tile

        Nothing ->
            TileType.sidewalk


getTileByTileInstance : Tile -> TileType.TileType
getTileByTileInstance tileInstance =
    case List.Extra.getAt tileInstance.tileId TileType.tiles of
        Just tile ->
            tile

        Nothing ->
            TileType.sidewalk
