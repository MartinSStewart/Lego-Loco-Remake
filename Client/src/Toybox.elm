module Toybox exposing (..)

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
import Lenses
import SpriteHelper
import Model exposing (..)
import Color
import Monocle.Lens as Lens


default : Toybox
default =
    Toybox (Point2 100 100) Nothing


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
            Lens.modify Lenses.toolbox (\a -> .set Lenses.viewPosition (getPosition windowSize a) a)
    in
        case msg of
            DragStart xy ->
                let
                    newModel =
                        model
                            |> Lens.modify (Lens.compose Lenses.toolbox Lenses.drag) (maybeCase (\a -> a) (Drag xy xy))
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
                            (Lens.compose Lenses.toolbox Lenses.drag)
                            (maybeCase (.set Lenses.current xy) (Drag xy xy))
                            model
                in
                    ( newModel, None )

            DragEnd xy ->
                let
                    newModel =
                        model
                            |> updateViewPosition
                            |> Lens.modify (Lens.compose Lenses.toolbox Lenses.drag) (\_ -> Nothing)
                in
                    ( newModel, None )

            NoOp ->
                ( model, None )

            TileSelect tileId ->
                ( model |> .set Lenses.editMode (PlaceTiles tileId), None )

            TileCategory _ ->
                ( model, None )

            EraserSelect ->
                ( model |> .set Lenses.editMode Eraser, None )

            BombSelect ->
                ( model, None )

            Undo ->
                ( model, None )


getPosition : Point2 Int -> Toybox -> Point2 Int
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
            Sprite.toybox |> .size

        toolboxLeftSize =
            Sprite.toyboxLeft |> .size
    in
        Point2 (toolboxSize.x + toolboxLeftSize.x) toolboxSize.y


toolboxLeftSize : Point2 Int
toolboxLeftSize =
    Sprite.toyboxLeft |> .size


toolboxHandleSize : Point2 Int
toolboxHandleSize =
    Sprite.toyboxHandle |> .size


insideToolbox : Point2 Int -> Point2 Int -> Toybox -> Bool
insideToolbox windowSize viewPoint toolbox =
    Point2.pointInRectangle (getPosition windowSize toolbox) toolboxSize viewPoint
        || Point2.pointInRectangle (toolboxHandlePosition windowSize toolbox) toolboxHandleSize viewPoint


toolboxHandlePosition : Point2 Int -> Toybox -> Point2 Int
toolboxHandlePosition windowSize toolbox =
    Point2 ((toolboxSize.x - toolboxHandleSize.x) // 2) (Sprite.toyboxHandle |> .origin |> .y)
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
            [ SpriteHelper.spriteView (Point2 toolboxLeftSize.x 0) Sprite.toybox
            , backgroundDiv
            , tileView (Point2 (6 + toolboxLeftSize.x) 16) model
            , menuView (Point2 6 13) model
            , div
                --We want to be able to click the menu buttons under this.
                [ style [ ( "pointer-events", "none" ) ] ]
                [ SpriteHelper.spriteView Point2.zero Sprite.toyboxLeft ]
            , div
                [ onMouseDown ]
                [ SpriteHelper.spriteView handleLocalPosition Sprite.toyboxHandle ]
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


menuView : Point2 Int -> Model -> Html ToolboxMsg
menuView pixelPosition model =
    let
        tileButtonMargin =
            Point2 3 3

        gridColumns =
            3

        menuButtonSize =
            Point2.add tileButtonMargin tileButtonLocalSize

        tileButtonLocalSize =
            Sprite.toyboxMenuButtonUp |> .size

        buttons =
            [ ( Sprite.toyboxRailroad, TileCategory 0, False )
            , ( Sprite.toyboxHouse, TileCategory 1, False )
            , ( Sprite.toyboxPlants, TileCategory 2, False )
            , ( Sprite.toyboxEraser, EraserSelect, model.editMode == Eraser )
            , ( Sprite.toyboxBomb, BombSelect, False )
            , ( Sprite.toyboxLeftArrow, Undo, False )
            ]
    in
        buttons
            |> List.indexedMap
                (\index ( sprite, msg, buttonPressed ) ->
                    let
                        position =
                            index
                                |> Point2.intToInt2 gridColumns
                                |> Point2.mult menuButtonSize
                                |> Point2.add pixelPosition
                    in
                        div [ onEvent "click" msg ]
                            [ SpriteHelper.spriteView
                                position
                                (ifThenElse
                                    buttonPressed
                                    Sprite.toyboxMenuButtonDown
                                    Sprite.toyboxMenuButtonUp
                                )
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
                                        [ Sprite.toyboxTileButtonDown |> .filepath |> background ]
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


subscriptions : Toybox -> Sub ToolboxMsg
subscriptions toolbox =
    case toolbox.drag of
        Just _ ->
            Sub.batch
                [ Mouse.moves DragAt
                , Mouse.ups DragEnd
                ]

        Nothing ->
            Sub.batch []
