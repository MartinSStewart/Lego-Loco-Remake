module Main exposing (..)

import Helpers exposing (..)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src, style)
import Html.Events exposing (on)
import Int2 exposing (Int2)
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
import Toolbox exposing (Toolbox)
import Window


---- MODEL ----


initModel : Model
initModel =
    Model
        (Int2 0 0)
        (Int2 500 500)
        []
        Toolbox.default
        Nothing
        0
        Nothing
        (Position 0 0)
        (Int2 1000 1000)


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.batch [ Task.perform WindowResize Window.size, [ Server.GetRegion (Int2 0 0) (Int2 1000 1000) ] |> Server.send ]
    )


gridToPixels : Int
gridToPixels =
    16


pixelsToGrid : Float
pixelsToGrid =
    1 / (toFloat gridToPixels)


viewToGrid : Int2 -> Model -> Int2
viewToGrid viewPoint model =
    viewPoint
        |> Int2.add model.viewPosition
        |> Int2.toFloat2
        |> Int2.rmultScalar pixelsToGrid
        |> Int2.floor


viewToTileGrid : Int2 -> Model -> TileType.TileType -> Int2
viewToTileGrid viewPoint model tile =
    tile.gridSize
        |> Int2.rdiv 2
        |> Int2.sub (viewToGrid viewPoint model)



---- UPDATE ----


type Msg
    = NoOp
    | KeyMsg Keyboard.KeyCode
    | MouseDown MouseEvents.MouseEvent
    | MouseUp Position
    | ToolboxMsg Toolbox.ToolboxMsg
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
            ( model |> toolbox.set (Toolbox.update model.windowSize toolboxMsg model.toolbox), Cmd.none )

        RotateTile wheelDelta ->
            rotateTile wheelDelta model

        MouseUp _ ->
            ( lastTilePosition.set Nothing model, Cmd.none )

        WindowResize newSize ->
            ( windowSize.set (Int2 newSize.width newSize.height) model, Cmd.none )

        WebSocketRecieve text ->
            ( Server.update text model, Cmd.none )


keyMsg : number -> Model -> ( Model, Cmd msg )
keyMsg keyCode model =
    let
        unit =
            -- Arrow keys
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
            Int2.multScalar unit gridToPixels |> Int2.add model.viewPosition
    in
        model
            |> viewPosition.set movement
            |> mouseMove model.mousePosCurrent


mouseDown : MouseEvents.MouseEvent -> Model -> ( Model, Cmd msg )
mouseDown mouseEvent model =
    let
        a =
            Debug.log "mouseDown" mouseEvent

        tileId =
            model.toolbox.selectedTileId

        tile =
            getTileOrDefault tileId

        position =
            (MouseEvents.relPos mouseEvent)

        tilePos =
            viewToTileGrid
                position
                model
                tile

        tileInstance =
            Tile tileId tilePos model.currentRotation

        newModel =
            model
                |> lastTilePosition.set (Just tilePos)
    in
        ( newModel, [ Server.AddTile tileInstance ] |> Server.send )


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


mouseMove : Int2 -> Model -> ( Model, Cmd msg )
mouseMove mousePos model =
    let
        tilePos =
            model.toolbox.selectedTileId
                |> getTileOrDefault
                |> viewToTileGrid mousePos model
    in
        if Toolbox.insideToolbox model.windowSize mousePos model.toolbox then
            ( currentTile.set Nothing model, Cmd.none )
        else
            let
                ( tiles, newModel ) =
                    model |> currentTile.set (Just tilePos) |> drawTiles tilePos

                cmd =
                    case tiles of
                        a :: rest ->
                            tiles |> List.map Server.AddTile |> Server.send

                        _ ->
                            Cmd.none
            in
                ( newModel, cmd )


drawTiles : Int2 -> Model -> ( List Tile, Model )
drawTiles newTilePosition model =
    let
        tileSize =
            model.toolbox.selectedTileId |> getTileOrDefault |> .gridSize

        tileInstance =
            Tile
                model.toolbox.selectedTileId
                newTilePosition
                model.currentRotation
    in
        case model.lastTilePosition of
            Nothing ->
                ( [], model )

            Just pos ->
                if Int2.rectangleCollision pos tileSize newTilePosition tileSize then
                    ( [], model )
                else
                    model
                        --|> modelAddTile tileInstance
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
                    [ tileView model (Tile model.toolbox.selectedTileId a model.currentRotation) True 9998 ]

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
                , Int2.negate model.viewPosition |> backgroundPosition
                ]
            ]
        <|
            tileViews
                ++ currentTileView
                ++ [ Toolbox.toolboxView 9999 model.windowSize toolbox |> Html.map (\a -> ToolboxMsg a) ]


tileView : Model -> Tile -> Bool -> Int -> Html msg
tileView model tileInstance seeThrough zIndex =
    let
        tile =
            getTileByTileInstance tileInstance

        sprite =
            rotSpriteGetAt tile.sprite tileInstance.rotationIndex

        pos =
            Int2.multScalar tileInstance.position gridToPixels
                |> Int2.add (Int2.negate sprite.pixelOffset)
                |> Int2.add (Int2.negate model.viewPosition)

        size =
            tile.gridSize
                |> Int2.add (Int2 1 1)
                |> Int2.mult (Int2 gridToPixels gridToPixels)

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
                    ++ Toolbox.absoluteStyle pos size
                    ++ seeThroughStyle
            ]
            []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Toolbox.subscriptions model.toolbox |> Sub.map (\a -> ToolboxMsg a)
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
