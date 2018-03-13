module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src, style)
import Keyboard
import List.Extra
import Point exposing (Point)
import Mouse


---- MODEL ----


type alias Model =
    { viewPosition : Point
    , viewSize : Point
    , tiles : List Tile
    , tileInstances : List TileInstance
    , defaultTile : Tile
    }


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


modelSetViewPosition : Point -> Model -> Model
modelSetViewPosition viewPosition model =
    { model | viewPosition = viewPosition }


modelAddTileInstance : TileInstance -> Model -> Model
modelAddTileInstance tileInstance model =
    { model | tileInstances = model.tileInstances ++ [ tileInstance ] }


modelGetTileOrDefault : Int -> Model -> Tile
modelGetTileOrDefault tileId model =
    case List.Extra.getAt tileId model.tiles of
        Just tile ->
            tile

        Nothing ->
            model.defaultTile


getTileByTileInstance : Model -> TileInstance -> Tile
getTileByTileInstance model tileInstance =
    case List.Extra.getAt tileInstance.tileId model.tiles of
        Just tile ->
            tile

        Nothing ->
            model.defaultTile


gridToPixels : Int
gridToPixels =
    16


pixelsToGrid : Float
pixelsToGrid =
    1 / (toFloat gridToPixels)



---- UPDATE ----


type Msg
    = NoOp
    | KeyMsg Keyboard.KeyCode
    | MouseDown Mouse.Position


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        KeyMsg keyCode ->
            let
                unit =
                    if keyCode == 37 then
                        Point -1 0
                    else if keyCode == 38 then
                        Point 0 -1
                    else if keyCode == 39 then
                        Point 1 0
                    else if keyCode == 40 then
                        Point 0 1
                    else
                        Point 0 0

                movement =
                    Point.mult unit (gridToPixels // 3)
            in
                ( modelSetViewPosition (Point.add model.viewPosition movement) model, Cmd.none )

        MouseDown mousePosition ->
            let
                tileId =
                    0

                tile =
                    modelGetTileOrDefault tileId model

                gridX =
                    (toFloat mousePosition.x * pixelsToGrid |> floor) - (tile.gridSize.x // 2)

                gridY =
                    (toFloat mousePosition.y * pixelsToGrid |> floor) - (tile.gridSize.x // 2)

                tileInstance =
                    TileInstance tileId (Point gridX gridY)

                -- (tile.gridSize.y // 2)
            in
                ( modelAddTileInstance tileInstance model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        tileViews =
            model.tileInstances |> List.sortBy (\a -> a.position.y) |> List.map (\a -> tileView model a)
    in
        div
            [ style
                [ ( "background-image", "url(\"grid.png\")" )
                , ( "width", "100%" )
                , ( "height", "100vh" )
                , ( "background-position", toString -model.viewPosition.x ++ "px " ++ toString -model.viewPosition.y ++ "px" )
                ]
            ]
            tileViews


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyMsg
        , Mouse.downs MouseDown
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
