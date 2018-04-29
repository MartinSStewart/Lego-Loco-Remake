module Helpers exposing (..)

import Json.Decode as Decode
import Html
import Html.Events as Events
import Point2 exposing (Point2)
import Model exposing (..)
import Lenses exposing (..)
import Monocle.Lens as Lens
import List.Extra
import TileType
import Mouse exposing (Position)
import Color exposing (Color)


maybeCase : (a -> b) -> b -> Maybe a -> Maybe b
maybeCase justCase nothingCase maybe =
    case maybe of
        Just a ->
            justCase a |> Just

        Nothing ->
            nothingCase |> Just


px : number -> String
px value =
    toString value ++ "px"


background : String -> ( String, String )
background url =
    ( "background-image", "url(\"" ++ url ++ "\")" )


backgroundColor : Color -> ( String, String )
backgroundColor color =
    let
        channels =
            Color.toRgb color

        text =
            [ toString channels.red
            , toString channels.green
            , toString channels.blue
            , toString channels.alpha
            ]
                |> String.join ","
    in
        ( "background-color", "rgb(" ++ text ++ ")" )


stylePosition : Point2 number -> String
stylePosition point =
    px point.x ++ " " ++ px point.y


backgroundPosition : Point2 number -> ( String, String )
backgroundPosition position =
    ( "background-position", stylePosition position )


onEvent : String -> b -> Html.Attribute b
onEvent eventName callback =
    Events.onWithOptions
        eventName
        { stopPropagation = True, preventDefault = True }
        (Decode.succeed callback)


onWheel : (Int -> msg) -> Html.Attribute msg
onWheel message =
    Events.on "wheel" (Decode.map message (Decode.at [ "deltaY" ] Decode.int))


modelAddTile : Tile -> Model -> Model
modelAddTile tile model =
    model |> Lens.modify tiles (List.filter (collidesWith tile >> not) >> (::) tile)


setMousePosCurrent : Position -> ( Model, Cmd msg ) -> ( Model, Cmd msg )
setMousePosCurrent position modelCmd =
    ( mousePosCurrent.set position (Tuple.first modelCmd), Tuple.second modelCmd )


collidesWith : Tile -> Tile -> Bool
collidesWith tileInstance0 tileInstance1 =
    let
        getTileSize tileInstance =
            getTileOrDefault tileInstance.tileId |> .gridSize
    in
        Point2.rectangleCollision
            tileInstance0.position
            (getTileSize tileInstance0)
            tileInstance1.position
            (getTileSize tileInstance1)


collisionsAt : Model -> Point2 Int -> Point2 Int -> List Tile
collisionsAt model gridPosition gridSize =
    let
        getTileSize tileInstance =
            getTileOrDefault tileInstance.tileId |> .gridSize
    in
        List.filter
            (\a -> Point2.rectangleCollision a.position (getTileSize a) gridPosition gridSize)
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
