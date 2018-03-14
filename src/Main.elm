module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src, style)
import Keyboard
import List.Extra
import Point exposing (Point)
import MouseEvents


---- MODEL ----


type alias Model =
    { viewPosition : Point
    , viewSize : Point
    , tileInstances : List TileInstance
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


type alias Toolbox =
    { viewPosition : Point
    , selectedTileId : Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model
        (Point 0 0)
        (Point 500 500)
        [ TileInstance 0 (Point 0 3), TileInstance 0 (Point 0 0) ]
    , Cmd.none
    )


tiles : List Tile
tiles =
    [ Tile "/house0.png" (Point 0 -10) "Red House" (Point 3 3)
    , Tile "/house0.png" (Point 0 -10) "Red House" (Point 3 3)
    ]


defaultTile : Tile
defaultTile =
    Tile "/house0.png" (Point 0 -10) "Red House" (Point 3 3)


modelSetViewPosition : Point -> Model -> Model
modelSetViewPosition viewPosition model =
    { model | viewPosition = viewPosition }


modelAddTileInstance : TileInstance -> Model -> Model
modelAddTileInstance tileInstance model =
    { model | tileInstances = model.tileInstances ++ [ tileInstance ] }


getTileOrDefault : Int -> Tile
getTileOrDefault tileId =
    case List.Extra.getAt tileId tiles of
        Just tile ->
            tile

        Nothing ->
            defaultTile


getTileByTileInstance : TileInstance -> Tile
getTileByTileInstance tileInstance =
    case List.Extra.getAt tileInstance.tileId tiles of
        Just tile ->
            tile

        Nothing ->
            defaultTile


gridToPixels : Int
gridToPixels =
    16


pixelsToGrid : Float
pixelsToGrid =
    1 / (toFloat gridToPixels)


viewToGrid : Point -> Model -> Point
viewToGrid viewPoint model =
    let
        gridX =
            (toFloat (viewPoint.x + model.viewPosition.x) * pixelsToGrid |> floor)

        gridY =
            (toFloat (viewPoint.y + model.viewPosition.y) * pixelsToGrid |> floor)
    in
        Point gridX gridY



---- UPDATE ----


type Msg
    = NoOp
    | KeyMsg Keyboard.KeyCode
    | MouseDown MouseEvents.MouseEvent


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
                    Point.mult unit (gridToPixels * 3)
            in
                ( modelSetViewPosition (Point.add model.viewPosition movement) model, Cmd.none )

        MouseDown mouseEvent ->
            let
                tileId =
                    0

                tile =
                    getTileOrDefault tileId

                gridPos =
                    viewToGrid (MouseEvents.relPos mouseEvent) model

                gridX =
                    gridPos.x - (tile.gridSize.x // 2)

                gridY =
                    gridPos.y - (tile.gridSize.x // 2)

                tileInstance =
                    TileInstance tileId (Point gridX gridY)
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
            [ MouseEvents.onClick MouseDown
            , style
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
            getTileByTileInstance tileInstance

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
