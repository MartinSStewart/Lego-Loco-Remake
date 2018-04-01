module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src, style)
import Keyboard
import Int2 exposing (Int2)
import MouseEvents
import Toolbox exposing (Toolbox)
import Helpers exposing (..)
import Mouse exposing (Position)
import Tiles exposing (..)
import Window
import Task
import Model exposing (..)
import Server


---- MODEL ----


init : ( Model, Cmd Msg )
init =
    ( Model
        (Int2 0 0)
        (Int2 500 500)
        []
        Toolbox.default
        (Just (Int2 0 3))
        0
        Nothing
        (Position 0 0)
        (Int2 1000 1000)
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
    let
        gridX =
            (toFloat (viewPoint.x + model.viewPosition.x) * pixelsToGrid |> floor)

        gridY =
            (toFloat (viewPoint.y + model.viewPosition.y) * pixelsToGrid |> floor)
    in
        Int2 gridX gridY


viewToTileGrid : Int2 -> Model -> TileType -> Int2
viewToTileGrid viewPoint model tile =
    let
        gridPos =
            viewToGrid viewPoint model

        gridX =
            gridPos.x - (tile.gridSize.x // 2)

        gridY =
            gridPos.y - (tile.gridSize.x // 2)
    in
        Int2 gridX gridY



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
                    Int2.multScalar unit gridToPixels |> Int2.add model.viewPosition

                newModel =
                    model
                        |> modelSetViewPosition movement
                        |> mouseMove model.mousePosCurrent
            in
                ( newModel, Cmd.none )

        MouseDown mouseEvent ->
            let
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
                        |> modelAddTile tileInstance
                        |> setLastTilePosition (Just position)
            in
                ( newModel, [ Server.AddTile tileInstance ] |> Server.send )

        MouseMoved xy ->
            ( mouseMove xy model |> setMousePosCurrent xy, Cmd.none )

        ToolboxMsg toolboxMsg ->
            ( Toolbox.update model.windowSize toolboxMsg model.toolbox |> setToolbox model, Cmd.none )

        RotateTile wheelDelta ->
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

        MouseUp _ ->
            ( { model | lastTilePosition = Nothing }, Cmd.none )

        WindowResize newSize ->
            ( { model | windowSize = Int2 newSize.width newSize.height }, Cmd.none )

        WebSocketRecieve text ->
            let
                a =
                    Debug.log "Message recieved" text
            in
                ( Server.update text model, Cmd.none )


mouseMove : Int2 -> Model -> Model
mouseMove mousePos model =
    let
        tilePos =
            model.toolbox.selectedTileId
                |> getTileOrDefault
                |> viewToTileGrid mousePos model
    in
        if Toolbox.insideToolbox model.windowSize mousePos model.toolbox then
            model |> setCurrentTile Nothing
        else
            model
                |> setCurrentTile (Just tilePos)
                |> drawTiles tilePos


drawTiles : Int2 -> Model -> Model
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
                model

            Just pos ->
                if Int2.rectangleCollision pos tileSize newTilePosition tileSize then
                    model
                else
                    modelAddTile tileInstance model |> setLastTilePosition (Just newTilePosition)



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        tileViews =
            model.tileInstances
                |> List.map (\a -> tileView model a False)

        toolbox =
            model.toolbox

        currentTileView =
            case model.currentTile of
                Just a ->
                    [ tileView model (Tile model.toolbox.selectedTileId a model.currentRotation) True ]

                Nothing ->
                    []
    in
        div
            [ MouseEvents.onMouseDown MouseDown
            , onWheel RotateTile
            , style
                [ background "grid.png"
                , ( "width", "100%" )
                , ( "height", "100vh" )
                , Int2.negate model.viewPosition |> backgroundPosition
                ]
            ]
        <|
            tileViews
                ++ currentTileView
                ++ [ Toolbox.toolboxView 9999 model.windowSize toolbox |> Html.map (\a -> ToolboxMsg a) ]


tileView : Model -> Tile -> Bool -> Html msg
tileView model tileInstance seeThrough =
    let
        tile =
            getTileByTileInstance tileInstance

        sprite =
            rotSpriteGetAt tile.sprite tileInstance.rotationIndex

        pos =
            Int2.multScalar tileInstance.position gridToPixels
                |> Int2.add sprite.pixelOffset
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
                , ( "z-index", toString tileInstance.position.y )
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
