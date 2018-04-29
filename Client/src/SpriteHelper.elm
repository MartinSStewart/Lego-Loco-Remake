module SpriteHelper exposing (..)

import Sprite exposing (Sprite)
import Html exposing (Html, div)
import Html.Attributes exposing (src, style)
import Helpers exposing (..)
import Int2 exposing (Int2, Float2)


spriteView : Int2 -> Sprite -> Html msg
spriteView topLeft sprite =
    div
        [ style <|
            [ background sprite.filepath
            , ( "background-repeat", "no-repeat" )
            ]
                ++ absoluteStyle (Int2.sub topLeft sprite.origin) sprite.size
        ]
        []


spriteViewAlign : Int2 -> Float2 -> Sprite -> Html msg
spriteViewAlign topLeft alignment sprite =
    let
        position =
            topLeft
                |> Int2.rsub sprite.origin
                |> Int2.rsub (Int2.mult alignment sprite.size)
    in
        div
            [ style <|
                [ background sprite.filepath
                , ( "background-repeat", "no-repeat" )
                ]
                    ++ absoluteStyle position sprite.size
            ]
            []


absoluteStyle : { x : number, y : number } -> { x : number, y : number } -> List ( String, String )
absoluteStyle pixelPosition pixelSize =
    [ ( "position", "absolute" )
    , ( "left", px pixelPosition.x )
    , ( "top", px pixelPosition.y )
    , ( "width", px pixelSize.x )
    , ( "height", px pixelSize.y )
    , ( "margin", "0px" )
    ]
