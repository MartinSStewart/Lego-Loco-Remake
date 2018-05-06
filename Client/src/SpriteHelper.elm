module SpriteHelper exposing (..)

import Model exposing (Sprite)
import Html exposing (Html, div)
import Html.Attributes exposing (src, style)
import Helpers exposing (..)
import Point2 exposing (Point2)


spriteView : Point2 Int -> Sprite -> Html msg
spriteView topLeft sprite =
    spriteViewWithStyle topLeft sprite []


spriteViewWithStyle : Point2 Int -> Sprite -> List ( String, String ) -> Html msg
spriteViewWithStyle topLeft sprite styleTuples =
    div
        [ style <|
            [ background sprite.filepath
            , ( "background-repeat", "no-repeat" )
            , ( "pointer-events", "none" )
            ]
                ++ absoluteStyle (Point2.sub topLeft sprite.origin) sprite.size
                ++ styleTuples
        ]
        []


spriteViewAlign : Point2 Int -> Point2 Float -> Sprite -> Html msg
spriteViewAlign topLeft alignment sprite =
    let
        alignmentOffset =
            sprite.size
                |> Point2.toFloat
                |> Point2.mult alignment
                |> Point2.floor

        position =
            topLeft
                |> Point2.rsub sprite.origin
                |> Point2.rsub alignmentOffset
    in
        div
            [ style <|
                [ background sprite.filepath
                , ( "background-repeat", "no-repeat" )
                ]
                    ++ absoluteStyle position sprite.size
            ]
            []
