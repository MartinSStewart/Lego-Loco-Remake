module Main exposing (..)

import Helpers exposing (..)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src, style)
import Html.Events exposing (on)
import Point2 exposing (Point2)
import Json.Decode
import Keyboard
import Lenses exposing (..)
import Monocle.Lens as Lens
import Model exposing (..)
import Mouse exposing (Position)
import MouseEvents
import Server
import Sprite
import Task
import TileHelper exposing (..)
import Toybox
import Window
import Tile
import SpriteHelper
import Config exposing (minGridPosition, maxGridPosition)


---- MODEL ----


initModel : Model
initModel =
    Model
        (Point2 0 0)
        (Point2 500 500)
        []
        Toybox.default
        0
        Nothing
        (Position 0 0)
        (Point2 1000 1000)
        Hand
        False


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.batch
        [ Task.perform WindowResize Window.size
        , [ Server.GetRegion (Point2 0 0) (Point2 1000 1000) ] |> Server.send
        ]
    )


gridToPixels : Int
gridToPixels =
    16


pixelsToGrid : Float
pixelsToGrid =
    1 / (toFloat gridToPixels)


viewToGrid : Point2 Int -> Model -> Point2 Int
viewToGrid viewPoint model =
    viewPoint
        |> Point2.add model.viewPosition
        |> Point2.toFloat
        |> Point2.rmultScalar pixelsToGrid
        |> Point2.floor


viewToTileGrid : Point2 Int -> Model -> TileTypeId -> Point2 Int
viewToTileGrid viewPoint model tileTypeId =
    Tile.tileTypeGridSize model.currentRotation (getTileOrDefault tileTypeId)
        |> Point2.rdiv 2
        |> Point2.sub (viewToGrid viewPoint model)



---- UPDATE ----


type Msg
    = NoOp
    | KeyMsg Keyboard.KeyCode
    | MouseDown MouseEvents.MouseEvent
    | MouseUp Position
    | ToolboxMsg Model.ToolboxMsg
    | MouseMoved Position
    | RotateTile Int
    | WindowResize Window.Size
    | WebSocketRecieve String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        KeyMsg keyCode ->
            keyMsg keyCode model

        MouseDown mouseEvent ->
            mouseDown mouseEvent model

        MouseMoved xy ->
            mouseMove xy model |> setMousePosCurrent xy

        ToolboxMsg toolboxMsg ->
            ( Toybox.update model.windowSize toolboxMsg model |> Tuple.first, Cmd.none )

        RotateTile wheelDelta ->
            rotateTile wheelDelta model

        MouseUp _ ->
            ( lastTilePosition.set Nothing model, Cmd.none )

        WindowResize newSize ->
            ( windowSize.set (Point2 newSize.width newSize.height) model, Cmd.none )

        WebSocketRecieve text ->
            ( Server.update text model, Cmd.none )


keyMsg : number -> Model -> ( Model, Cmd msg )
keyMsg keyCode model =
    let
        unit =
            -- Arrow keys
            if keyCode == 37 then
                Point2 -1 0
            else if keyCode == 38 then
                Point2 0 -1
            else if keyCode == 39 then
                Point2 1 0
            else if keyCode == 40 then
                Point2 0 1
            else
                Point2 0 0

        -- ctrlDown =
        --     if keyCode ==  then
        --
        --     else
        movement =
            Point2.multScalar unit gridToPixels |> Point2.add model.viewPosition
    in
        model
            |> viewPosition.set movement
            |> mouseMove model.mousePosCurrent


mouseDown : MouseEvents.MouseEvent -> Model -> ( Model, Cmd msg )
mouseDown mouseEvent model =
    let
        position =
            MouseEvents.relPos mouseEvent
    in
        case model.editMode of
            PlaceTiles tileId ->
                let
                    tilePos =
                        viewToTileGrid
                            position
                            model
                            tileId

                    a =
                        Debug.log "pos" tilePos

                    tileInstance =
                        TileBaseData tileId tilePos model.currentRotation |> Helpers.initTile

                    newModel =
                        model |> lastTilePosition.set (Just tilePos)
                in
                    ( newModel, [ Server.AddTile tileInstance ] |> Server.send )

            Eraser ->
                erase (viewToGrid position model) model

            Hand ->
                let
                    gridPos =
                        viewToGrid position model

                    cmd =
                        model
                            |> Helpers.collisionsAt gridPos Point2.one
                            |> List.map (.baseData >> Server.ClickTile)
                            |> Server.send
                in
                    ( model, cmd )


erase : Point2 Int -> Model -> ( Model, Cmd msg )
erase gridPosition model =
    let
        command =
            model
                |> collisionsAt gridPosition Point2.one
                |> List.map (.baseData >> Server.RemoveTile)
                |> Server.send

        a =
            Debug.log "asdf" command

        newModel =
            model |> lastTilePosition.set (Just gridPosition)
    in
        ( newModel, command )


rotateTile : Int -> Model -> ( Model, Cmd msg )
rotateTile wheelDelta model =
    let
        rotateBy =
            if wheelDelta > 0 then
                1
            else
                -1

        newModel =
            model |> Lens.modify Lenses.currentRotation (\a -> (a + rotateBy) % directions)
    in
        ( newModel, Cmd.none )


mouseMove : Point2 Int -> Model -> ( Model, Cmd msg )
mouseMove mousePos model =
    if Toybox.insideToolbox model.windowSize mousePos model.toolbox then
        ( model, Cmd.none )
    else
        case model.editMode of
            PlaceTiles tileId ->
                let
                    tilePos =
                        viewToTileGrid mousePos model tileId

                    ( tiles, newModel ) =
                        model
                            |> drawTiles tilePos tileId

                    cmd =
                        case tiles of
                            a :: rest ->
                                tiles |> List.map Server.AddTile |> Server.send

                            _ ->
                                Cmd.none
                in
                    ( newModel, cmd )

            Eraser ->
                let
                    gridPosition =
                        viewToGrid mousePos model
                in
                    case model.lastTilePosition of
                        Just lastTilePosition ->
                            if gridPosition == lastTilePosition then
                                ( model, Cmd.none )
                            else
                                erase gridPosition model

                        Nothing ->
                            ( model, Cmd.none )

            Hand ->
                ( model, Cmd.none )


drawTiles : Point2 Int -> Model.TileTypeId -> Model -> ( List Tile, Model )
drawTiles newTilePosition tileId model =
    let
        tileInstance =
            TileBaseData
                tileId
                newTilePosition
                model.currentRotation
                |> Helpers.initTile

        tileSize =
            Tile.gridSize tileInstance.baseData
    in
        case model.lastTilePosition of
            Nothing ->
                ( [], model )

            Just pos ->
                if Point2.rectangleCollision pos tileSize newTilePosition tileSize then
                    ( [], model )
                else
                    model
                        |> lastTilePosition.set (Just newTilePosition)
                        |> (,) [ tileInstance ]



---- VIEW ----


onMouseDown : (String -> msg) -> Html.Attribute msg
onMouseDown tagger =
    on "mousedown" (Json.Decode.map tagger Html.Events.targetValue)


view : Model -> Html Msg
view model =
    let
        tileZIndex =
            -minGridPosition.y

        currentTileZIndex =
            maxGridPosition.y - minGridPosition.y + 1

        toyboxZIndex =
            currentTileZIndex + 1

        tileViews =
            model.tiles |> List.map (\a -> tileView model a False (tileZIndex + a.baseData.position.y))

        toolbox =
            model.toolbox

        currentTileView =
            case model.editMode of
                PlaceTiles tileId ->
                    let
                        mouseTilePos =
                            viewToTileGrid
                                model.mousePosCurrent
                                model
                                tileId
                    in
                        [ tileView
                            model
                            (TileBaseData tileId mouseTilePos model.currentRotation |> Helpers.initTile)
                            True
                            currentTileZIndex
                        ]

                Eraser ->
                    []

                Hand ->
                    []
    in
        div
            [ MouseEvents.onMouseDown MouseDown
            , onWheel RotateTile
            , style
                [ Sprite.grid |> .filepath |> background
                , ( "width", "100%" )
                , ( "height", "100vh" )
                , Point2.negate model.viewPosition |> backgroundPosition
                ]
            ]
        <|
            tileViews
                ++ currentTileView
                ++ [ Toybox.toolboxView toyboxZIndex model.windowSize model |> Html.map (\a -> ToolboxMsg a) ]


tileView : Model -> Tile -> Bool -> Int -> Html msg
tileView model tile seeThrough zIndex =
    let
        tileType =
            Helpers.getTileTypeByTile tile.baseData

        sprite =
            rotSpriteGetAt tileType.sprite tile.baseData.rotationIndex

        pos =
            Point2.multScalar tile.baseData.position gridToPixels
                |> Point2.rsub model.viewPosition

        a =
            if seeThrough then
                pos
            else
                Debug.log "pos" pos

        size =
            tileType.gridSize
                |> Point2.mult (Point2 gridToPixels gridToPixels)

        styleTuples =
            [ ( "z-index", toString zIndex ), ( "pointer-events", "none" ) ]
                ++ if seeThrough then
                    [ ( "opacity", "0.5" ) ]
                   else
                    []
    in
        SpriteHelper.spriteViewWithStyle pos sprite styleTuples



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Toybox.subscriptions model.toolbox |> Sub.map (\a -> ToolboxMsg a)
        , Sub.batch
            [ Keyboard.downs KeyMsg
            , Mouse.moves MouseMoved -- This move update needs to happen after the toolbox subscriptions.
            , Mouse.ups MouseUp
            , Window.resizes WindowResize
            , Server.subscription WebSocketRecieve
            ]
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
