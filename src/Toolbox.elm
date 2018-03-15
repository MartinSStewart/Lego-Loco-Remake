module Toolbox exposing (..)

import Helpers exposing (..)
import Int2 exposing (Int2)
import Html exposing (Html, div, img, text)
import Html.Attributes exposing (src, style)
import Html.Events as Events
import Json.Decode as Decode
import Helpers exposing (..)


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


{-| Size of toolbox in view coordinates.
-}
toolboxSize : Int2
toolboxSize =
    Int2 180 234


toolboxHandleSize : Int2
toolboxHandleSize =
    Int2 64 32


onEvent : String -> b -> Html.Attribute b
onEvent eventName callback =
    Events.onWithOptions
        eventName
        { stopPropagation = True, preventDefault = True }
        (Decode.succeed callback)


toolboxView :
    Toolbox
    -> msg
    -> Html.Attribute msg
    -> Html msg
toolboxView toolbox noOp drag =
    let
        position =
            toolbox.viewPosition

        handlePosition =
            Int2 ((toolboxSize.x - toolboxHandleSize.x) // 2) -14
    in
        div
            [ onEvent "click" noOp
            , style
                [ background "/toolbox.png"
                , ( "position", "absolute" )
                , ( "left", withSuffix position.x "px" )
                , ( "top", withSuffix position.y "px" )
                , ( "width", withSuffix toolboxSize.x "px" )
                , ( "height", withSuffix toolboxSize.y "px" )
                , ( "background-color", "gray" )
                , ( "margin", "0px" )
                ]
            ]
            [ div
                [ drag
                , style
                    [ background "/toolboxHandle.png"
                    , ( "position", "absolute" )
                    , ( "left", withSuffix handlePosition.x "px" )
                    , ( "top", withSuffix handlePosition.y "px" )
                    , ( "width", withSuffix toolboxHandleSize.x "px" )
                    , ( "height", withSuffix toolboxHandleSize.y "px" )
                    ]
                ]
                []
            ]
