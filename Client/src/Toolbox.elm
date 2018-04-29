module Toolbox exposing (..)

import Helpers exposing (..)
import Point2 exposing (Point2)
import Html exposing (Html, div, img, text)
import Html.Attributes exposing (src, style)
import Html.Events as Events exposing (on)
import Json.Decode as Decode
import Helpers exposing (..)
import Mouse
import TileType
import Sprite
import Lenses exposing (..)
import SpriteHelper
import Model exposing (..)
import Color


default : Toolbox
default =
    Toolbox (Point2 100 100) 0 Nothing


toolboxTileSize : Int
toolboxTileSize =
    54


toolboxTileMargin : Int
toolboxTileMargin =
    3


absoluteStyle : Point2 number -> Point2 number -> List ( String, String )
absoluteStyle pixelPosition pixelSize =
    [ ( "position", "absolute" )
    , ( "left", px pixelPosition.x )
    , ( "top", px pixelPosition.y )
    , ( "width", px pixelSize.x )
    , ( "height", px pixelSize.y )
    , ( "margin", "0px" )
    ]


update : Point2 Int -> ToolboxMsg -> Toolbox -> Toolbox
update windowSize msg toolbox =
    case msg of
        DragStart xy ->
            let
                newDrag =
                    case toolbox.drag of
                        Nothing ->
                            Just (Drag xy xy)

                        -- If we were already dragging then don't do anything here.
                        Just a ->
                            Just a
            in
                toolbox
                    {- Update the toolbox position.
                       It's visible position might not match viewPosition if the window has been resized.
                    -}
                    |> viewPosition.set (getPosition windowSize toolbox)
                    |> drag.set newDrag

        DragAt xy ->
            let
                newDrag =
                    case toolbox.drag of
                        Just drag ->
                            Just { drag | current = xy }

                        Nothing ->
                            Just <| Drag xy xy
            in
                toolbox |> drag.set newDrag

        DragEnd xy ->
            toolbox
                |> viewPosition.set (getPosition windowSize toolbox)
                |> drag.set Nothing

        NoOp ->
            toolbox

        TileSelect tileId ->
            { toolbox | selectedTileId = tileId }

        TileCategory _ ->
            Debug.crash "TODO"

        EraserSelect ->
            Debug.crash "TODO"

        BombSelect ->
            Debug.crash "TODO"

        Undo ->
            Debug.crash "TODO"


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


toolboxView : Int -> Point2 Int -> Toolbox -> Html ToolboxMsg
toolboxView zIndex windowSize toolbox =
    let
        position =
            getPosition windowSize toolbox

        handleLocalPosition =
            Point2 ((toolboxLeftSize.x - toolboxHandleSize.x) // 2) 0

        backgroundMargin =
            Point2 2 2

        --Used to prevent anything under the toolbox from bleeding through.
        --This can happen if the user has DPI set to something other than 100%.
        backgroundDiv =
            div
                [ style <|
                    Helpers.backgroundColor Color.black
                        :: absoluteStyle backgroundMargin
                            (backgroundMargin
                                |> Point2.rmultScalar 2
                                |> Point2.sub toolboxLeftSize
                            )
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
            , tileView (Point2 (6 + toolboxLeftSize.x) 16) toolbox
            , menuView (Point2 6 13) toolbox
            , SpriteHelper.spriteView Point2.zero Sprite.toolboxLeft
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

        gridWidth =
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
                                |> Point2.intToInt2 gridWidth
                                |> Point2.mult menuButtonSize
                                |> Point2.add pixelPosition
                    in
                        div []
                            [ SpriteHelper.spriteView position Sprite.toolboxMenuButtonUp
                            , SpriteHelper.spriteViewAlign (menuButtonSize |> Point2.rdiv 2 |> Point2.add position) (Point2 0.5 0.5) sprite
                            ]
                )
            |> div []


tileView : Point2 Int -> Toolbox -> Html ToolboxMsg
tileView pixelPosition toolbox =
    let
        tileButtonMargin =
            Point2 3 3

        tileButtonLocalSize =
            Point2 54 54

        tileButtonSize =
            Point2.add tileButtonMargin tileButtonLocalSize

        gridSize =
            Point2 3 3

        getPosition =
            Point2.intToInt2 gridSize.x
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
                            if toolbox.selectedTileId == index then
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
