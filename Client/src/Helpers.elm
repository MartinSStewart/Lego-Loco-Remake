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
import Model exposing (..)
import Mouse exposing (Position)
import Color exposing (Color)
import Tile


initTile : TileBaseData -> Tile
initTile tileBaseData =
    Tile
        tileBaseData
        (getTileOrDefault tileBaseData.tileId |> .data |> initTileData)


initTileData : TileTypeData -> TileData
initTileData tileTypeData =
    case tileTypeData of
        Basic _ ->
            TileBasic

        Rail _ _ ->
            TileRail []

        RailFork _ _ _ ->
            TileRailFork [] False

        Depot _ ->
            TileDepot [] True


absoluteStyle : Point2 number -> Point2 number -> List ( String, String )
absoluteStyle pixelPosition pixelSize =
    [ ( "position", "absolute" )
    , ( "left", px pixelPosition.x )
    , ( "top", px pixelPosition.y )
    , ( "width", px pixelSize.x )
    , ( "height", px pixelSize.y )
    , ( "margin", "0px" )
    ]


selectedTileId : Model -> Maybe Model.TileTypeId
selectedTileId model =
    case model.editMode of
        PlaceTiles id ->
            Just id

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


intMax : Int
intMax =
    2147483647


intMin : Int
intMin =
    -2147483648


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


addTile : Tile -> Model -> Model
addTile tile model =
    Lens.modify
        tiles
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


setMousePosCurrent : Position -> ( Model, Cmd msg ) -> ( Model, Cmd msg )
setMousePosCurrent position modelCmd =
    ( mousePosCurrent.set position (Tuple.first modelCmd), Tuple.second modelCmd )


collidesWith : TileBaseData -> TileBaseData -> Bool
collidesWith tileBase0 tileBase1 =
    Point2.rectangleCollision
        tileBase0.position
        (Tile.gridSize tileBase0)
        tileBase1.position
        (Tile.gridSize tileBase1)


collisionsAt : Point2 Int -> Point2 Int -> Model -> List Tile
collisionsAt gridPosition gridSize model =
    List.filter
        (\a ->
            Point2.rectangleCollision
                a.baseData.position
                (Tile.gridSize a.baseData)
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


directions : number
directions =
    4


rotToList : Rot a -> List a
rotToList rotSprite =
    case rotSprite of
        Rot1 single ->
            [ single ]

        Rot2 horizontal vertical ->
            [ horizontal, vertical ]

        Rot4 right up left down ->
            [ right, up, left, down ]


rotGetAt : Rot a -> Int -> a
rotGetAt rotSprite index =
    let
        spriteList =
            rotToList rotSprite

        sprite =
            List.Extra.getAt (index % List.length spriteList) spriteList
    in
        case sprite of
            Just a ->
                a

            Nothing ->
                Debug.crash "There is no way this can happen."
