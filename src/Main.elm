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
import Tiles exposing (..)


---- MODEL ----


type alias Model =
    { viewPosition : Int2 -- Position of view in pixel coordinates.
    , viewSize : Int2 -- Size of view in pixel coordinates.
    , tileInstances : List TileInstance
    , toolbox : Toolbox
    , currentTile : Maybe Int2
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
        []
        Toolbox.default
        (Just (Int2 0 3))
    , Cmd.none
    )


modelSetViewPosition : Int2 -> Model -> Model
modelSetViewPosition viewPosition model =
    { model | viewPosition = viewPosition }


modelAddTileInstance : TileInstance -> Model -> Model
modelAddTileInstance tileInstance model =
    let
        newTileInstances =
            List.filter (\a -> not (collidesWith a tileInstance)) model.tileInstances ++ [ tileInstance ]
    in
        { model | tileInstances = newTileInstances }


collidesWith : TileInstance -> TileInstance -> Bool
collidesWith tileInstance0 tileInstance1 =
    let
        getTileSize tileInstance =
            getTileOrDefault tileInstance.tileId |> .gridSize
    in
        Int2.rectangleCollision
            tileInstance0.position
            (getTileSize tileInstance0)
            tileInstance1.position
            (getTileSize tileInstance1)


collisionsAt : Model -> Int2 -> Int2 -> List TileInstance
collisionsAt model gridPosition gridSize =
    let
        getTileSize tileInstance =
            getTileOrDefault tileInstance.tileId |> .gridSize
    in
        List.filter
            (\a -> Int2.rectangleCollision a.position (getTileSize a) gridPosition gridSize)
            model.tileInstances


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


viewToTileGrid : Int2 -> Model -> Tile -> Int2
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
    | ToolboxMsg Toolbox.ToolboxMsg
    | MouseMoved Position


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
                    Int2.multScalar unit (gridToPixels // 3)
            in
                ( modelSetViewPosition (Int2.add model.viewPosition movement) model, Cmd.none )

        MouseDown mouseEvent ->
            let
                tileId =
                    0

                tile =
                    getTileOrDefault tileId

                tileInstance =
                    viewToTileGrid (MouseEvents.relPos mouseEvent) model tile |> TileInstance tileId
            in
                ( modelAddTileInstance tileInstance model, Cmd.none )

        MouseMoved xy ->
            ( mouseMove xy model, Cmd.none )

        ToolboxMsg toolboxMsg ->
            ( Toolbox.update toolboxMsg model.toolbox |> setToolbox model, Cmd.none )


setToolbox : { b | toolbox : a } -> c -> { b | toolbox : c }
setToolbox model toolbox =
    { model | toolbox = toolbox }


mouseMove : Int2 -> Model -> Model
mouseMove mousePos model =
    let
        newCurrentTile =
            if Toolbox.insideToolbox mousePos model.toolbox then
                Nothing
            else
                model.toolbox.selectedTileId |> getTileOrDefault |> viewToTileGrid mousePos model |> Just
    in
        { model | currentTile = newCurrentTile }



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        tileViews =
            model.tileInstances |> List.sortBy (\a -> a.position.y) |> List.map (\a -> tileView model a False)

        toolbox =
            model.toolbox

        currentTileView =
            case model.currentTile of
                Just a ->
                    [ tileView model (TileInstance model.toolbox.selectedTileId a) True ]

                Nothing ->
                    []
    in
        div
            [ MouseEvents.onClick MouseDown
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
                ++ [ Toolbox.toolboxView toolbox |> Html.map (\a -> ToolboxMsg a) ]


tileView : Model -> TileInstance -> Bool -> Html msg
tileView model tileInstance seeThrough =
    let
        tile =
            getTileByTileInstance tileInstance

        x =
            tile.sprite.pixelOffset.x + gridToPixels * tileInstance.position.x - model.viewPosition.x

        y =
            tile.sprite.pixelOffset.y + gridToPixels * tileInstance.position.y - model.viewPosition.y

        size =
            tile.gridSize |> Int2.add (Int2 1 1) |> Int2.mult (Int2 gridToPixels gridToPixels)

        seeThroughStyle =
            if seeThrough then
                [ ( "opacity", "0.5" ) ]
            else
                []
    in
        div
            [ style <|
                [ background "house0.png"
                , ( "background-repeat", "no-repeat" )
                , ( "pointer-events", "none" )
                ]
                    ++ Toolbox.absoluteStyle (Int2 x y) size
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
