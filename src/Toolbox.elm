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


update : ToolboxMsg -> Toolbox -> Toolbox
update msg toolbox =
    case msg of
        DragStart xy ->
            let
                newDrag =
                    case toolbox.drag of
                        Nothing ->
                            (Just (Drag xy xy))

                        Just a ->
                            Just a
            in
                { toolbox | drag = newDrag }

        DragAt xy ->
            let
                newDrag =
                    case toolbox.drag of
                        Just drag ->
                            Just { drag | current = xy }

                        Nothing ->
                            Just <| Drag xy xy

                newToolbox =
                    { toolbox | drag = newDrag }
            in
                newToolbox

        DragEnd xy ->
            let
                newToolbox =
                    setViewPosition (getPosition toolbox) toolbox
            in
                { newToolbox | drag = Nothing }

        NoOp ->
            toolbox

        TileSelect tileId ->
            { toolbox | selectedTileId = tileId }


getPosition : Toolbox -> Int2
getPosition toolbox =
    let
        position =
            toolbox.viewPosition
    in
        case toolbox.drag of
            Nothing ->
                position

            Just { start, current } ->
                Int2
                    (position.x + current.x - start.x)
                    (position.y + current.y - start.y)


{-| Size of toolbox in view coordinates.
-}
toolboxSize : Int2
toolboxSize =
    Int2 180 234


toolboxHandleSize : Int2
toolboxHandleSize =
    Int2 64 37


insideToolbox : Int2 -> Toolbox -> Bool
insideToolbox viewPoint toolbox =
    Int2.pointInsideRectangle (getPosition toolbox) toolboxSize viewPoint
        || Int2.pointInsideRectangle (toolboxHandlePosition toolbox) toolboxHandleSize viewPoint


toolboxHandlePosition : Toolbox -> Int2
toolboxHandlePosition toolbox =
    Int2 ((toolboxSize.x - toolboxHandleSize.x) // 2) -18 |> Int2.add (getPosition toolbox)



---- VIEW ----


toolboxView : Toolbox -> Html ToolboxMsg
toolboxView toolbox =
    let
        position =
            getPosition toolbox

        handlePosition =
            Int2 ((toolboxSize.x - toolboxHandleSize.x) // 2) -18
    in
        div
            [ onEvent "click" NoOp --Prevents clicks from propagating to UI underneath.
            , style <|
                [ background "/toolbox.png" ]
                    ++ absoluteStyle position toolboxSize
            ]
            [ tileView (Int2 5 16)
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


tileView : Int2 -> Html ToolboxMsg
tileView pixelPosition =
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
                        div
                            [ onEvent "click" (TileSelect index)
                            , style <|
                                [ background a.icon.filepath
                                , ( "background-repeat", "no-repeat" )
                                , imageOffset a |> backgroundPosition
                                ]
                                    ++ absoluteStyle (getPosition index) tileButtonLocalSize
                            ]
                            []
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
