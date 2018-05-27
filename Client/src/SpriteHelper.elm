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
            ]
                ++ absoluteStyle (Point2.sub topLeft sprite.origin) sprite.size
                ++ styleTuples
        ]
        []


spriteViewScaled : Point2 Int -> Point2 Float -> Sprite -> Html msg
spriteViewScaled topLeft scale sprite =
    spriteViewScaledWithStyle topLeft scale sprite []


spriteViewScaledWithStyle : Point2 Int -> Point2 Float -> Sprite -> List ( String, String ) -> Html msg
spriteViewScaledWithStyle topLeft scale sprite styleTuples =
    let
        percent value =
            toString (value * 100) ++ "%"
    in
        div
            [ style <|
                [ background sprite.filepath
                , ( "background-repeat", "no-repeat" )
                , ( "background-size", (percent scale.x) ++ " " ++ (percent scale.y) )
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
