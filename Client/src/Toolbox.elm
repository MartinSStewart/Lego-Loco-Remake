module Toolbox exposing (..)

import Helpers exposing (..)
import Int2 exposing (Int2)
import Html exposing (Html, div, img, text)
import Html.Attributes exposing (src, style)
import Html.Events as Events exposing (on)
import Json.Decode as Decode
import Helpers exposing (..)
import Tiles
import Mouse


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


type alias Drag =
    { start : Mouse.Position
    , current : Mouse.Position
    }


default : Toolbox
default =
    Toolbox (Int2 100 100) 0 Nothing


setViewPosition : Int2 -> Toolbox -> Toolbox
setViewPosition viewPosition toolbox =
    { toolbox | viewPosition = viewPosition }


setDrag : Maybe Drag -> Toolbox -> Toolbox
setDrag drag toolbox =
    { toolbox | drag = drag }


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
                    -- Update the toolbox position. It's visible position might not match viewPosition if the window has been resized.
                    |> setViewPosition (getPosition windowSize toolbox)
                    |> setDrag newDrag

        DragAt xy ->
            let
                newDrag =
                    case toolbox.drag of
                        Just drag ->
                            Just { drag | current = xy }

                        Nothing ->
                            Just <| Drag xy xy
            in
                toolbox |> setDrag newDrag

        DragEnd xy ->
            toolbox
                |> setViewPosition (getPosition windowSize toolbox)
                |> setDrag Nothing

        NoOp ->
            toolbox

        TileSelect tileId ->
            { toolbox | selectedTileId = tileId }


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
    Int2 180 234


toolboxHandleSize : Int2
toolboxHandleSize =
    Int2 64 37


insideToolbox : Int2 -> Int2 -> Toolbox -> Bool
insideToolbox windowSize viewPoint toolbox =
    Int2.pointInRectangle (getPosition windowSize toolbox) toolboxSize viewPoint
        || Int2.pointInRectangle (toolboxHandlePosition windowSize toolbox) toolboxHandleSize viewPoint


toolboxHandlePosition : Int2 -> Toolbox -> Int2
toolboxHandlePosition windowSize toolbox =
    Int2 ((toolboxSize.x - toolboxHandleSize.x) // 2) -18 |> Int2.add (getPosition windowSize toolbox)



---- VIEW ----


toolboxView : Int -> Int2 -> Toolbox -> Html ToolboxMsg
toolboxView zIndex windowSize toolbox =
    let
        position =
            getPosition windowSize toolbox

        handlePosition =
            Int2 ((toolboxSize.x - toolboxHandleSize.x) // 2) -18
    in
        div
            [ onEvent "click" NoOp --Prevents clicks from propagating to UI underneath.
            , onEvent "mousedown" NoOp
            , style <|
                [ background "/toolbox.png", ( "z-index", toString zIndex ) ]
                    ++ absoluteStyle position toolboxSize
            ]
            [ tileView (Int2 5 16) toolbox
            , div
                [ onMouseDown
                , style <|
                    [ background "/toolboxHandle.png" ]
                        ++ absoluteStyle handlePosition toolboxHandleSize
                ]
                []
            ]


onMouseDown : Html.Attribute ToolboxMsg
onMouseDown =
    on "mousedown" (Decode.map DragStart Mouse.position)


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

        getPosition index =
            Int2 (index // gridSize.x) (index % gridSize.x)
                |> Int2.mult tileButtonSize
                |> Int2.add pixelPosition

        imageOffset tile =
            Int2.div (Int2.sub tileButtonLocalSize tile.icon.pixelSize) 2

        tileDiv =
            Tiles.tiles
                |> List.indexedMap
                    (\index a ->
                        let
                            buttonDownDiv =
                                if toolbox.selectedTileId == index then
                                    div
                                        [ style <|
                                            [ background "/toolboxTileButtonDown.png" ]
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
    in
        div [] tileDiv



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
