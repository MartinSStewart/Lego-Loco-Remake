module Main exposing (..)

import Config exposing (maxGridPosition, minGridPosition)
import Helpers exposing (..)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src, style)
import Keyboard
import Lenses exposing (..)
import Model exposing (..)
import Monocle.Lens as Lens
import Mouse exposing (Position)
import MouseEvents
import Point2 exposing (Point2)
import Server
import Sprite
import Task
import Tile
import Toybox
import Window
import Cursor
import Grid
import Rectangle exposing (Rectangle)
import Set


---- MODEL ----


initModel : Model
initModel =
    Model
        (Point2 0 0)
        Grid.init
        Toybox.default
        0
        Nothing
        (Position 0 0)
        (Point2 1000 1000)
        Hand
        False
        Set.empty


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.batch
        [ Task.perform WindowResize Window.size
        ]
    )



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
            mouseMove xy ( model, Cmd.none ) |> setMousePosCurrent xy

        ToolboxMsg toolboxMsg ->
            ( Toybox.update model.windowSize toolboxMsg model |> Tuple.first, Cmd.none )

        RotateTile wheelDelta ->
            rotateTile wheelDelta model

        MouseUp _ ->
            ( lastTilePosition.set Nothing model, Cmd.none )

        WindowResize { width, height } ->
            moveView (Rectangle model.viewPosition (Point2 width height)) model

        WebSocketRecieve text ->
            ( Server.update text model, Cmd.none )


keyMsg : number -> Model -> ( Model, Cmd Msg )
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
                Point2.zero

        -- ctrlDown =
        --     if keyCode ==  then
        --
        --     else
        movement =
            Point2.multScalar unit Tile.gridToPixels |> Point2.add model.viewPosition
    in
        if unit == Point2.zero then
            ( model, Cmd.none )
        else
            model
                |> moveView (Rectangle movement model.windowSize)
                |> mouseMove model.mousePosCurrent


moveView : Rectangle Int -> Model -> ( Model, Cmd Msg )
moveView viewRegion model =
    let
        ( grid, updates ) =
            Grid.update viewRegion model.tiles

        updatesSet =
            updates |> List.map Point2.toTuple |> Set.fromList

        getRegionsCmd =
            Set.diff updatesSet model.pendingGetRegions
                |> Set.toList
                |> List.map (\a -> Server.GetRegion (Point2.fromTuple a) Point2.one)
                |> Server.send

        newModel =
            { model
                | viewPosition = viewRegion.topLeft
                , windowSize = viewRegion.size
                , tiles = grid
                , pendingGetRegions = Set.union updatesSet model.pendingGetRegions
            }
    in
        ( newModel
        , getRegionsCmd
        )


mouseDown : MouseEvents.MouseEvent -> Model -> ( Model, Cmd Msg )
mouseDown mouseEvent model =
    let
        position =
            MouseEvents.relPos mouseEvent
    in
        case model.editMode of
            PlaceTiles tileId ->
                let
                    tilePos =
                        Tile.viewToTileGrid
                            position
                            model.viewPosition
                            model.currentRotation
                            tileId

                    tileInstance =
                        TileBaseData tileId tilePos model.currentRotation |> Tile.initTile

                    newModel =
                        model |> lastTilePosition.set (Just tilePos)
                in
                    ( newModel, [ Server.AddTile tileInstance ] |> Server.send )

            Eraser ->
                erase (Tile.viewToGrid position model.viewPosition) ( model, Cmd.none )

            Hand ->
                let
                    gridPos =
                        Tile.viewToGrid position model.viewPosition

                    cmd =
                        model.tiles
                            |> Grid.collisionsAt gridPos Point2.one
                            |> List.map (.baseData >> Server.ClickTile)
                            |> Server.send
                in
                    ( model, cmd )


erase : Point2 Int -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
erase gridPosition ( model, cmdMsg ) =
    let
        command =
            model.tiles
                |> Grid.collisionsAt gridPosition Point2.one
                |> List.map (.baseData >> Server.RemoveTile)
                |> Server.send

        newModel =
            model |> lastTilePosition.set (Just gridPosition)
    in
        ( newModel, Cmd.batch [ cmdMsg, command ] )


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


mouseMove : Point2 Int -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
mouseMove mousePos ( model, cmdMsg ) =
    if Toybox.insideToolbox model.windowSize mousePos model.toolbox then
        ( model, cmdMsg )
    else
        case model.editMode of
            PlaceTiles tileId ->
                let
                    tilePos =
                        Tile.viewToTileGrid mousePos model.viewPosition model.currentRotation tileId

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
                    ( newModel, Cmd.batch [ cmdMsg, cmd ] )

            Eraser ->
                let
                    gridPosition =
                        Tile.viewToGrid mousePos model.viewPosition
                in
                    case model.lastTilePosition of
                        Just lastTilePosition ->
                            if gridPosition == lastTilePosition then
                                ( model, cmdMsg )
                            else
                                erase gridPosition ( model, cmdMsg )

                        Nothing ->
                            ( model, cmdMsg )

            Hand ->
                ( model, cmdMsg )


drawTiles : Point2 Int -> Model.TileTypeId -> Model -> ( List Tile, Model )
drawTiles newTilePosition tileId model =
    let
        tileInstance =
            TileBaseData
                tileId
                newTilePosition
                model.currentRotation
                |> Tile.initTile

        tileSize =
            Tile.tileGridSize tileInstance.baseData
    in
        case model.lastTilePosition of
            Nothing ->
                ( [], model )

            Just pos ->
                if Rectangle.overlap pos tileSize newTilePosition tileSize then
                    ( [], model )
                else
                    model
                        |> lastTilePosition.set (Just newTilePosition)
                        |> (,) [ tileInstance ]



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        tileZIndex =
            -minGridPosition.y

        currentTileZIndex =
            maxGridPosition.y - minGridPosition.y + 1

        toyboxZIndex =
            currentTileZIndex + 1

        toolbox =
            model.toolbox

        currentTileView =
            case model.editMode of
                PlaceTiles tileId ->
                    let
                        mouseTilePos =
                            Tile.viewToTileGrid
                                model.mousePosCurrent
                                model.viewPosition
                                model.currentRotation
                                tileId
                    in
                        if Toybox.insideToolbox model.windowSize model.mousePosCurrent model.toolbox then
                            []
                        else
                            [ div [ style <| Helpers.absoluteStyle (Point2.negate model.viewPosition) Point2.zero ]
                                [ Tile.tileView
                                    (TileBaseData tileId mouseTilePos model.currentRotation |> Tile.initTile)
                                    True
                                    currentTileZIndex
                                ]
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
            Grid.view tileZIndex (Rectangle model.viewPosition model.windowSize) model.tiles
                :: currentTileView
                ++ [ Toybox.toolboxView toyboxZIndex model.windowSize model |> Html.map ToolboxMsg
                   , Cursor.cursorView model
                   ]



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
