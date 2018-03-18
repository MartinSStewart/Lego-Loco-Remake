module Toolbox exposing (..)

import Helpers exposing (..)
import Int2 exposing (Int2)
import Html exposing (Html, div, img, text)
import Html.Attributes exposing (src, style)
import Html.Events as Events
import Json.Decode as Decode
import Helpers exposing (..)
import Tiles


type alias Toolbox =
    { viewPosition : Int2 -- Position of toolbox in view coordinates
    , selectedTileId : Int
    , isDragged : Bool
    }


default : Toolbox
default =
    Toolbox (Int2 100 100) 0 False


toolboxSetIsDragged : Bool -> Toolbox -> Toolbox
toolboxSetIsDragged isDragged toolbox =
    { toolbox | isDragged = isDragged }


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


{-| Size of toolbox in view coordinates.
-}
toolboxSize : Int2
toolboxSize =
    Int2 180 234


toolboxHandleSize : Int2
toolboxHandleSize =
    Int2 64 32


insideToolbox : Int2 -> Toolbox -> Bool
insideToolbox viewPoint toolbox =
    Int2.pointInsideRectangle toolbox.viewPosition toolboxSize viewPoint
        || Int2.pointInsideRectangle (toolboxHandlePosition toolbox) toolboxHandleSize viewPoint


toolboxHandlePosition : Toolbox -> Int2
toolboxHandlePosition toolbox =
    Int2 ((toolboxSize.x - toolboxHandleSize.x) // 2) -14 |> Int2.add toolbox.viewPosition


onEvent : String -> b -> Html.Attribute b
onEvent eventName callback =
    Events.onWithOptions
        eventName
        { stopPropagation = True, preventDefault = True }
        (Decode.succeed callback)


toolboxView : Toolbox -> msg -> Html.Attribute msg -> Html msg
toolboxView toolbox noOp drag =
    let
        position =
            toolbox.viewPosition

        handlePosition =
            Int2 ((toolboxSize.x - toolboxHandleSize.x) // 2) -14
    in
        div
            [ onEvent "click" noOp
            , style <|
                [ background "/toolbox.png" ]
                    ++ absoluteStyle position toolboxSize
            ]
            [ tileView (Int2 5 16) toolbox
            , div
                [ drag
                , style <|
                    [ background "/toolboxHandle.png" ]
                        ++ absoluteStyle handlePosition toolboxHandleSize
                ]
                []
            ]


tileView : Int2 -> Toolbox -> Html msg
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
            Int2 (index // gridSize.x) (index % gridSize.x) |> Int2.mult tileButtonSize |> Int2.add pixelPosition

        imageOffset tile =
            Int2.div (Int2.sub tileButtonLocalSize tile.icon.pixelSize) 2

        tileDiv =
            Tiles.tiles
                |> List.indexedMap
                    (\index a ->
                        div
                            [ style <|
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
