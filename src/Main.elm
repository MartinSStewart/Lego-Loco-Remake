module Main exposing (..)

import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src, style)
import List.Extra


---- MODEL ----


type alias Model =
    { viewPosition : Point
    , viewSize : Point
    , tiles : List Tile
    , tileInstances : List TileInstance
    , defaultTile : Tile
    }


type alias Point =
    { x : Int, y : Int }


type alias Tile =
    { imageName : String
    , imageOffset : Point
    , name : String
    , gridSize : Point
    }


type alias TileInstance =
    { tileId : Int
    , position : Point
    }


init : ( Model, Cmd Msg )
init =
    ( Model
        (Point 0 0)
        (Point 500 500)
        [ Tile "/house0.png" (Point 0 -10) "Red House" (Point 3 3)
        ]
        [ TileInstance 0 (Point 0 3), TileInstance 0 (Point 0 0) ]
      <|
        Tile "/house0.png" (Point 0 -10) "Red House" (Point 3 3)
    , Cmd.none
    )


getTileByTileInstance : Model -> TileInstance -> Tile
getTileByTileInstance model tileInstance =
    case List.Extra.getAt tileInstance.tileId model.tiles of
        Just tile ->
            tile

        Nothing ->
            model.defaultTile


gridToPixels : number
gridToPixels =
    16



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        tileViews =
            model.tileInstances |> List.sortBy (\a -> a.position.y) |> List.map (\a -> tileView model a)
    in
        div [] tileViews


tileView : Model -> TileInstance -> Html msg
tileView model tileInstance =
    let
        tile =
            getTileByTileInstance model tileInstance

        x =
            tile.imageOffset.x + gridToPixels * tileInstance.position.x - model.viewPosition.x

        y =
            tile.imageOffset.y + gridToPixels * tileInstance.position.y - model.viewPosition.y
    in
        img
            [ src "/house0.png"
            , style
                [ ( "position", "absolute" )
                , ( "left", toString x ++ "px" )
                , ( "top", toString y ++ "px" )
                , ( "margin", "0px" )
                ]
            ]
            []



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
