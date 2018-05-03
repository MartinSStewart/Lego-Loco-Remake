module Main exposing (..)

import Helpers exposing (..)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src, style)
import Html.Events exposing (on)
import Point2 exposing (Point2)
import Json.Decode
import Keyboard
import Lenses exposing (..)
import Model exposing (..)
import Mouse exposing (Position)
import MouseEvents
import Server
import Sprite
import Task
import TileHelper exposing (..)
import TileType
import Toybox
import Window
import Tile


---- MODEL ----


initModel : Model
initModel =
    Model
        (Point2 0 0)
        (Point2 500 500)
        []
        Toybox.default
        Nothing
        0
        Nothing
        (Position 0 0)
        (Point2 1000 1000)
        (PlaceTiles 0)


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


viewToTileGrid : Point2 Int -> Model -> TileType.TileType -> Point2 Int
viewToTileGrid viewPoint model tile =
    tile.gridSize
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
            (MouseEvents.relPos mouseEvent)
    in
        case model.editMode of
            PlaceTiles tileId ->
                let
                    tile =
                        getTileOrDefault tileId

                    tilePos =
                        viewToTileGrid
                            position
                            model
                            tile

                    tileInstance =
                        Tile tileId tilePos model.currentRotation

                    newModel =
                        model |> lastTilePosition.set (Just tilePos)
                in
                    ( newModel, [ Server.AddTile tileInstance ] |> Server.send )

            Eraser ->
                erase (viewToGrid position model) model

            Hand ->
                ( model, Cmd.none )


erase : Point2 Int -> Model -> ( Model, Cmd msg )
erase gridPosition model =
    let
        command =
            model
                |> collisionsAt gridPosition Point2.one
                |> List.map Server.RemoveTile
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
            { model | currentRotation = (model.currentRotation + rotateBy) % directions }
    in
        ( newModel, Cmd.none )


mouseMove : Point2 Int -> Model -> ( Model, Cmd msg )
mouseMove mousePos model =
    if Toybox.insideToolbox model.windowSize mousePos model.toolbox then
        ( currentTile.set Nothing model, Cmd.none )
    else
        case model.editMode of
            PlaceTiles tileId ->
                let
                    tilePos =
                        tileId
                            |> getTileOrDefault
                            |> viewToTileGrid mousePos model

                    ( tiles, newModel ) =
                        model
                            |> currentTile.set (Just tilePos)
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


drawTiles : Point2 Int -> Int -> Model -> ( List Tile, Model )
drawTiles newTilePosition tileId model =
    let
        tileInstance =
            Tile
                tileId
                newTilePosition
                model.currentRotation

        tileSize =
            Tile.gridSize tileInstance
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
        tileViews =
            model.tiles |> List.map (\a -> tileView model a False a.position.y)

        toolbox =
            model.toolbox

        currentTileView =
            case model.currentTile of
                Just a ->
                    case model.editMode of
                        PlaceTiles tileId ->
                            [ tileView model (Tile tileId a model.currentRotation) True 9998 ]

                        Eraser ->
                            []

                        Hand ->
                            []

                Nothing ->
                    []

        decode decoder =
            Debug.log "asdf" NoOp
    in
        div
            [ MouseEvents.onMouseDown MouseDown

            --onChange decode
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
                ++ [ Toybox.toolboxView 9999 model.windowSize model |> Html.map (\a -> ToolboxMsg a) ]


tileView : Model -> Tile -> Bool -> Int -> Html msg
tileView model tileInstance seeThrough zIndex =
    let
        tile =
            getTileByTileInstance tileInstance

        sprite =
            rotSpriteGetAt tile.sprite tileInstance.rotationIndex

        pos =
            Point2.multScalar tileInstance.position gridToPixels
                |> Point2.add (Point2.negate sprite.origin)
                |> Point2.add (Point2.negate model.viewPosition)

        size =
            tile.gridSize
                |> Point2.add (Point2 1 1)
                |> Point2.mult (Point2 gridToPixels gridToPixels)

        seeThroughStyle =
            if seeThrough then
                [ ( "opacity", "0.5" ) ]
            else
                []
    in
        div
            [ style <|
                [ background sprite.filepath
                , ( "background-repeat", "no-repeat" )
                , ( "pointer-events", "none" )
                , ( "z-index", toString zIndex )
                ]
                    ++ Helpers.absoluteStyle pos size
                    ++ seeThroughStyle
            ]
            []



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
