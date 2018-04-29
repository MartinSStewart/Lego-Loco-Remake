module Toolbox exposing (..)

import Helpers exposing (..)
import Int2 exposing (Int2)
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


type alias Toolbox =
    { viewPosition : Int2 -- Position of toolbox in view coordinates
    , selectedTileId : Int
    , drag : Maybe Drag
    }


type ToolboxMsg
    = NoOp
    | DragStart Int2
    | DragAt Mouse.Position
    | DragEnd Int2
    | TileSelect Int
    | TileCategory Int
    | EraserSelect
    | BombSelect
    | Undo


type alias Drag =
    { start : Mouse.Position
    , current : Mouse.Position
    }


default : Toolbox
default =
    Toolbox (Int2 100 100) 0 Nothing


toolboxTileSize : Int
toolboxTileSize =
    54


toolboxTileMargin : Int
toolboxTileMargin =
    3


absoluteStyle : Int2 -> Int2 -> List ( String, String )
absoluteStyle pixelPosition pixelSize =
    [ ( "position", "absolute" )
    , ( "left", px pixelPosition.x )
    , ( "top", px pixelPosition.y )
    , ( "width", px pixelSize.x )
    , ( "height", px pixelSize.y )
    , ( "margin", "0px" )
    ]


update : Int2 -> ToolboxMsg -> Toolbox -> Toolbox
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


getPosition : Int2 -> Toolbox -> Int2
getPosition windowSize toolbox =
    let
        position =
            case toolbox.drag of
                Nothing ->
                    toolbox.viewPosition

                Just { start, current } ->
                    toolbox.viewPosition
                        |> Int2.add current
                        |> Int2.add (Int2.negate start)

        maxPosition =
            Int2.sub windowSize toolboxSize
    in
        position
            |> Int2.max Int2.zero
            |> Int2.min maxPosition


{-| Size of toolbox in view coordinates.
-}
toolboxSize : Int2
toolboxSize =
    let
        toolboxSize =
            Sprite.toolbox |> .size

        toolboxLeftSize =
            Sprite.toolboxLeft |> .size
    in
        Int2 (toolboxSize.x + toolboxLeftSize.x) toolboxSize.y


toolboxLeftSize : Int2
toolboxLeftSize =
    Sprite.toolboxLeft |> .size


toolboxHandleSize : Int2
toolboxHandleSize =
    Sprite.toolboxHandle |> .size


insideToolbox : Int2 -> Int2 -> Toolbox -> Bool
insideToolbox windowSize viewPoint toolbox =
    Int2.pointInRectangle (getPosition windowSize toolbox) toolboxSize viewPoint
        || Int2.pointInRectangle (toolboxHandlePosition windowSize toolbox) toolboxHandleSize viewPoint


toolboxHandlePosition : Int2 -> Toolbox -> Int2
toolboxHandlePosition windowSize toolbox =
    Int2 ((toolboxSize.x - toolboxHandleSize.x) // 2) (Sprite.toolboxHandle |> .origin |> .y)
        |> Int2.add (getPosition windowSize toolbox)



---- VIEW ----


toolboxView : Int -> Int2 -> Toolbox -> Html ToolboxMsg
toolboxView zIndex windowSize toolbox =
    let
        position =
            getPosition windowSize toolbox

        handleLocalPosition =
            Int2 ((toolboxLeftSize.x - toolboxHandleSize.x) // 2) 0
    in
        div
            [ onEvent "click" NoOp --Prevents clicks from propagating to UI underneath.
            , onEvent "mousedown" NoOp
            , style <| ( "z-index", toString zIndex ) :: absoluteStyle position toolboxSize
            ]
            [ SpriteHelper.spriteView (Int2 toolboxLeftSize.x 0) Sprite.toolbox
            , tileView (Int2 (6 + toolboxLeftSize.x) 16) toolbox
            , menuView (Int2 6 13) toolbox
            , SpriteHelper.spriteView Int2.zero Sprite.toolboxLeft
            , div
                [ onMouseDown ]
                [ SpriteHelper.spriteView handleLocalPosition Sprite.toolboxHandle ]
            ]


onMouseDown : Html.Attribute ToolboxMsg
onMouseDown =
    on "mousedown" (Decode.map DragStart Mouse.position)


indexedMap2 : Int -> (Int2 -> a -> b) -> List a -> List b
indexedMap2 width mapper list =
    let
        getPosition index =
            Int2 (index // width) (index % width)
    in
        List.indexedMap (\index a -> mapper (getPosition index) a) list


menuView : Int2 -> Toolbox -> Html ToolboxMsg
menuView pixelPosition toolbox =
    let
        tileButtonMargin =
            Int2 3 3

        gridWidth =
            3

        menuButtonSize =
            Int2.add tileButtonMargin tileButtonLocalSize

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
                            Int2.intToInt2 gridWidth index
                                |> Int2.mult menuButtonSize
                                |> Int2.add pixelPosition
                    in
                        div []
                            [ SpriteHelper.spriteView position Sprite.toolboxMenuButtonUp
                            , SpriteHelper.spriteViewAlign position (Float2 0.5 0.5) sprite
                            ]
                )
            |> div []


tileView : Int2 -> Toolbox -> Html ToolboxMsg
tileView pixelPosition toolbox =
    let
        tileButtonMargin =
            Int2 3 3

        tileButtonLocalSize =
            Int2 54 54

        tileButtonSize =
            Int2.add tileButtonMargin tileButtonLocalSize

        gridSize =
            Int2 3 3

        getPosition =
            Int2.intToInt2 gridSize.x
                >> Int2.mult tileButtonSize
                >> Int2.add pixelPosition

        imageOffset tile =
            Int2.div (Int2.sub tileButtonLocalSize tile.icon.size) 2
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
                                            ++ absoluteStyle Int2.zero tileButtonLocalSize
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
                                        ++ absoluteStyle Int2.zero tileButtonLocalSize
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
