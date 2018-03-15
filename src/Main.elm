module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src, style)
import Keyboard
import List.Extra
import Int2 exposing (Int2)
import MouseEvents
import Toolbox exposing (Toolbox)
import Helpers exposing (..)
import Mouse exposing (Position)
import Json.Decode as Decode
import Html.Events exposing (on)


---- MODEL ----


type alias Model =
    { viewPosition : Int2 -- Position of view in pixel coordinates.
    , viewSize : Int2 -- Size of view in pixel coordinates.
    , tileInstances : List TileInstance
    , toolbox : Toolbox
    , drag : Maybe Drag
    }


type alias Drag =
    { start : Position
    , current : Position
    }


type alias Tile =
    { imageName : String
    , imageOffset : Int2
    , name : String
    , gridSize : Int2
    }


type alias TileInstance =
    { tileId : Int
    , position : Int2
    }


modelSetToolbox : Model -> Toolbox -> Model
modelSetToolbox model toolbox =
    { model | toolbox = toolbox }


modelSetToolboxViewPosition : Model -> Int2 -> Model
modelSetToolboxViewPosition model viewPosition =
    Toolbox.setViewPosition viewPosition model.toolbox |> modelSetToolbox model


init : ( Model, Cmd Msg )
init =
    ( Model
        (Int2 0 0)
        (Int2 500 500)
        [ TileInstance 0 (Int2 0 3), TileInstance 0 (Int2 0 0) ]
        Toolbox.default
        Nothing
    , Cmd.none
    )


tiles : List Tile
tiles =
    [ Tile "/house0.png" (Int2 0 -10) "Red House" (Int2 3 3)
    , Tile "/house0.png" (Int2 0 -10) "Red House" (Int2 3 3)
    ]


defaultTile : Tile
defaultTile =
    Tile "/house0.png" (Int2 0 -10) "Red House" (Int2 3 3)


modelSetViewPosition : Int2 -> Model -> Model
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


viewToGrid : Int2 -> Model -> Int2
viewToGrid viewPoint model =
    let
        gridX =
            (toFloat (viewPoint.x + model.viewPosition.x) * pixelsToGrid |> floor)

        gridY =
            (toFloat (viewPoint.y + model.viewPosition.y) * pixelsToGrid |> floor)
    in
        Int2 gridX gridY



---- UPDATE ----


type Msg
    = NoOp
    | KeyMsg Keyboard.KeyCode
    | MouseDown MouseEvents.MouseEvent
    | DragStart Position
    | DragAt Position
    | DragEnd Position


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        drag =
            model.drag

        position =
            model.toolbox.viewPosition
    in
        case msg of
            NoOp ->
                ( model, Cmd.none )

            KeyMsg keyCode ->
                let
                    unit =
                        if keyCode == 37 then
                            Int2 -1 0
                        else if keyCode == 38 then
                            Int2 0 -1
                        else if keyCode == 39 then
                            Int2 1 0
                        else if keyCode == 40 then
                            Int2 0 1
                        else
                            Int2 0 0

                    movement =
                        Int2.mult unit (gridToPixels // 3)
                in
                    ( modelSetViewPosition (Int2.add model.viewPosition movement) model, Cmd.none )

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
                        TileInstance tileId (Int2 gridX gridY)
                in
                    ( modelAddTileInstance tileInstance model, Cmd.none )

            DragStart xy ->
                ( { model | drag = (Just (Drag xy xy)) }, Cmd.none )

            DragAt xy ->
                let
                    newDrag =
                        case model.drag of
                            Just drag ->
                                Just { drag | current = xy }

                            Nothing ->
                                Just <| Drag xy xy

                    newModel =
                        { model | drag = newDrag }
                in
                    ( newModel, Cmd.none )

            --position (Maybe.map (\{ start } -> Drag start xy) drag)
            DragEnd xy ->
                let
                    newModel =
                        modelSetToolboxViewPosition model <| getPosition model
                in
                    ( { newModel | drag = Nothing }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        tileViews =
            model.tileInstances |> List.sortBy (\a -> a.position.y) |> List.map (\a -> tileView model a)

        stylePosition point =
            withSuffix point.x "px " ++ withSuffix point.y "px"

        realPosition =
            getPosition model

        toolbox =
            model.toolbox
    in
        div
            [ MouseEvents.onClick MouseDown
            , style
                [ background "grid.png"
                , ( "width", "100%" )
                , ( "height", "100vh" )
                , ( "background-position", Int2.negate model.viewPosition |> stylePosition )
                ]
            ]
        <|
            tileViews
                ++ [ Toolbox.toolboxView { toolbox | viewPosition = realPosition } NoOp onMouseDown ]


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
                , ( "left", withSuffix x "px" )
                , ( "top", withSuffix y "px" )
                , ( "margin", "0px" )
                , ( "pointer-events", "none" )
                ]
            ]
            []


getPosition : Model -> Position
getPosition model =
    let
        position =
            model.toolbox.viewPosition
    in
        case model.drag of
            Nothing ->
                position

            Just { start, current } ->
                Position
                    (position.x + current.x - start.x)
                    (position.y + current.y - start.y)


onMouseDown : Html.Attribute Msg
onMouseDown =
    on "mousedown" (Decode.map DragStart Mouse.position)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Nothing ->
            Sub.batch
                [ Keyboard.downs KeyMsg
                ]

        Just _ ->
            Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
