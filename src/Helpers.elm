module Helpers exposing (..)

import Json.Decode as Decode
import Html
import Html.Events as Events
import Int2 exposing (Int2)


px : number -> String
px value =
    toString value ++ "px"


background : String -> ( String, String )
background url =
    ( "background-image", "url(\"" ++ url ++ "\")" )


stylePosition : Int2 -> String
stylePosition point =
    px point.x ++ " " ++ px point.y


backgroundPosition : Int2 -> ( String, String )
backgroundPosition position =
    ( "background-position", stylePosition position )


onEvent : String -> b -> Html.Attribute b
onEvent eventName callback =
    Events.onWithOptions
        eventName
        { stopPropagation = True, preventDefault = True }
        (Decode.succeed callback)
