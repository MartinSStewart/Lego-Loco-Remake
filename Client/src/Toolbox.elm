module Toolbox exposing (..)

import Helpers exposing (..)
import Point2 exposing (Point2)
import Html exposing (Html, div, img, text)
import Html.Attributes exposing (src, style)
import Html.Events as Events exposing (on)
import Json.Decode as Decode
import Helpers
import Mouse
import TileType
import Sprite
import Lenses exposing (..)
import SpriteHelper
import Model exposing (..)
import Color
import Monocle.Lens as Lens


default : Toolbox
default =
    Toolbox (Point2 100 100) Nothing


toolboxTileSize : Int
toolboxTileSize =
    54


toolboxTileMargin : Int
toolboxTileMargin =
    3


update : Point2 Int -> ToolboxMsg -> Model -> ( Model, ToolboxCmd )
update windowSize msg model =
    let
        updateViewPosition =
            Lens.modify toolbox (\a -> viewPosition.set (getPosition windowSize a) a)
    in
        case msg of
            DragStart xy ->
                let
                    newModel =
                        model
                            |> Lens.modify (Lens.compose toolbox drag) (maybeCase (\a -> a) (Drag xy xy))
                            {- Update the toolbox position.
                               Its visible position might not match viewPosition if the window has been resized.
                            -}
                            |> updateViewPosition
                in
                    ( newModel, None )

            DragAt xy ->
                let
                    newModel =
                        Lens.modify
                            (Lens.compose toolbox drag)
                            (maybeCase (current.set xy) (Drag xy xy))
                            model
                in
                    ( newModel, None )

            DragEnd xy ->
                let
                    newModel =
                        model
                            |> updateViewPosition
                            |> Lens.modify (Lens.compose toolbox drag) (\_ -> Nothing)
                in
                    ( newModel, None )

            NoOp ->
                ( model, None )

            TileSelect tileId ->
                ( model |> editMode.set (PlaceTiles tileId), None )

            TileCategory _ ->
                ( model, None )

            EraserSelect ->
                ( editMode.set Eraser model, None )

            BombSelect ->
                ( model, None )

            Undo ->
                ( model, None )


getPosition : Point2 Int -> Toolbox -> Point2 Int
getPosition windowSize toolbox =
    let
        position =
            case toolbox.drag of
                Nothing ->
                    toolbox.viewPosition

                Just { start, current } ->
                    toolbox.viewPosition
                        |> Point2.add current
                        |> Point2.add (Point2.negate start)

        maxPosition =
            Point2.sub windowSize toolboxSize
    in
        position
            |> Point2.max Point2.zero
            |> Point2.min maxPosition


{-| Size of toolbox in view coordinates.
-}
toolboxSize : Point2 Int
toolboxSize =
    let
        toolboxSize =
            Sprite.toolbox |> .size

        toolboxLeftSize =
            Sprite.toolboxLeft |> .size
    in
        Point2 (toolboxSize.x + toolboxLeftSize.x) toolboxSize.y


toolboxLeftSize : Point2 Int
toolboxLeftSize =
    Sprite.toolboxLeft |> .size


toolboxHandleSize : Point2 Int
toolboxHandleSize =
    Sprite.toolboxHandle |> .size


insideToolbox : Point2 Int -> Point2 Int -> Toolbox -> Bool
insideToolbox windowSize viewPoint toolbox =
    Point2.pointInRectangle (getPosition windowSize toolbox) toolboxSize viewPoint
        || Point2.pointInRectangle (toolboxHandlePosition windowSize toolbox) toolboxHandleSize viewPoint


toolboxHandlePosition : Point2 Int -> Toolbox -> Point2 Int
toolboxHandlePosition windowSize toolbox =
    Point2 ((toolboxSize.x - toolboxHandleSize.x) // 2) (Sprite.toolboxHandle |> .origin |> .y)
        |> Point2.add (getPosition windowSize toolbox)



---- VIEW ----


toolboxView : Int -> Point2 Int -> Model -> Html ToolboxMsg
toolboxView zIndex windowSize model =
    let
        toolbox =
            model.toolbox

        position =
            getPosition windowSize toolbox

        handleLocalPosition =
            Point2 ((toolboxLeftSize.x - toolboxHandleSize.x) // 2) 0

        --Used to prevent anything under the toolbox from bleeding through.
        --This can happen if the user has DPI set to something other than 100%.
        backgroundDiv =
            let
                margin =
                    Point2 2 2

                size =
                    margin
                        |> Point2.rmultScalar 2
                        |> Point2.sub toolboxLeftSize
            in
                div
                    [ style <|
                        Helpers.backgroundColor Color.black
                            :: absoluteStyle margin size
                    ]
                    []
    in
        div
            [ onEvent "click" NoOp --Prevents clicks from propagating to UI underneath.
            , onEvent "mousedown" NoOp
            , style <| ( "z-index", toString zIndex ) :: absoluteStyle position toolboxSize
            ]
            [ SpriteHelper.spriteView (Point2 toolboxLeftSize.x 0) Sprite.toolbox
            , backgroundDiv
            , tileView (Point2 (6 + toolboxLeftSize.x) 16) model
            , menuView (Point2 6 13) toolbox
            , div
                --We want to be able to click the menu buttons under this.
                [ style [ ( "pointer-events", "none" ) ] ]
                [ SpriteHelper.spriteView Point2.zero Sprite.toolboxLeft ]
            , div
                [ onMouseDown ]
                [ SpriteHelper.spriteView handleLocalPosition Sprite.toolboxHandle ]
            ]


onMouseDown : Html.Attribute ToolboxMsg
onMouseDown =
    on "mousedown" (Decode.map DragStart Mouse.position)


indexedMap2 : Int -> (Point2 Int -> a -> b) -> List a -> List b
indexedMap2 width mapper list =
    let
        getPosition index =
            Point2 (index // width) (index % width)
    in
        List.indexedMap (\index a -> mapper (getPosition index) a) list


menuView : Point2 Int -> Toolbox -> Html ToolboxMsg
menuView pixelPosition toolbox =
    let
        tileButtonMargin =
            Point2 3 3

        gridColumns =
            3

        menuButtonSize =
            Point2.add tileButtonMargin tileButtonLocalSize

        tileButtonLocalSize =
            Sprite.toolboxMenuButtonUp |> .size

        buttons =
            [ ( Sprite.toolboxRailroad, TileCategory 0 )
            , ( Sprite.toolboxHouse, TileCategory 1 )
            , ( Sprite.toolboxPlants, TileCategory 2 )
            , ( Sprite.toolboxEraser, EraserSelect )
            , ( Sprite.toolboxBomb, BombSelect )
            , ( Sprite.toolboxLeftArrow, Undo )
            ]
    in
        buttons
            |> List.indexedMap
                (\index ( sprite, msg ) ->
                    let
                        position =
                            index
                                |> Point2.intToInt2 gridColumns
                                |> Point2.mult menuButtonSize
                                |> Point2.add pixelPosition
                    in
                        div [ onEvent "click" msg ]
                            [ SpriteHelper.spriteView position Sprite.toolboxMenuButtonUp
                            , SpriteHelper.spriteViewAlign
                                (menuButtonSize |> Point2.rdiv 2 |> Point2.add position)
                                (Point2 0.5 0.5)
                                sprite
                            ]
                )
            |> div []


tileView : Point2 Int -> Model -> Html ToolboxMsg
tileView pixelPosition model =
    let
        toolbox =
            model.toolbox

        tileButtonMargin =
            Point2 3 3

        tileButtonLocalSize =
            Point2 54 54

        tileButtonSize =
            Point2.add tileButtonMargin tileButtonLocalSize

        gridColumns =
            3

        getPosition =
            Point2.intToInt2 gridColumns
                >> Point2.mult tileButtonSize
                >> Point2.add pixelPosition

        imageOffset tile =
            Point2.div (Point2.sub tileButtonLocalSize tile.icon.size) 2
    in
        TileType.tiles
            |> List.indexedMap
                (\index a ->
                    let
                        buttonDownDiv =
                            if Helpers.selectedTileId model == Just index then
                                div
                                    [ style <|
                                        [ Sprite.toolboxTileButtonDown |> .filepath |> background ]
                                            ++ absoluteStyle Point2.zero tileButtonLocalSize
                                    ]
                                    []
                            else
                                div [] []
                    in
                        div
                            [ onEvent "click" (TileSelect index)
                            , style <|
                                absoluteStyle (getPosition index) tileButtonLocalSize
                            ]
                            [ buttonDownDiv
                            , div
                                [ style <|
                                    [ background a.icon.filepath
                                    , ( "background-repeat", "no-repeat" )
                                    , imageOffset a |> backgroundPosition
                                    ]
                                        ++ absoluteStyle Point2.zero tileButtonLocalSize
                                ]
                                []
                            ]
                )
            |> div []



-- SUBSCRIPTIONS


subscriptions : Toolbox -> Sub ToolboxMsg
subscriptions toolbox =
    case toolbox.drag of
        Just _ ->
            Sub.batch
                [ Mouse.moves DragAt
                , Mouse.ups DragEnd
                ]

        Nothing ->
            Sub.batch []
