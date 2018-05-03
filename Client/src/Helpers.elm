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
import Tile


absoluteStyle : Point2 number -> Point2 number -> List ( String, String )
absoluteStyle pixelPosition pixelSize =
    [ ( "position", "absolute" )
    , ( "left", px pixelPosition.x )
    , ( "top", px pixelPosition.y )
    , ( "width", px pixelSize.x )
    , ( "height", px pixelSize.y )
    , ( "margin", "0px" )
    ]


selectedTileId : Model -> Maybe Int
selectedTileId model =
    case model.editMode of
        PlaceTiles int ->
            Just int

        Eraser ->
            Nothing

        Hand ->
            Nothing


ifThenElse : Bool -> a -> a -> a
ifThenElse bool ifTrue ifFalse =
    if bool then
        ifTrue
    else
        ifFalse


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
    Point2.rectangleCollision
        tileInstance0.position
        (Tile.gridSize tileInstance0)
        tileInstance1.position
        (Tile.gridSize tileInstance1)


collisionsAt : Point2 Int -> Point2 Int -> Model -> List Tile
collisionsAt gridPosition gridSize model =
    List.filter
        (\a -> Point2.rectangleCollision a.position (Tile.gridSize a) gridPosition gridSize)
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
