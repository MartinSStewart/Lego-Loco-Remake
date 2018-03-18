module Helpers exposing (..)


px : number -> String
px value =
    toString value ++ "px"


background : String -> ( String, String )
background url =
    ( "background-image", "url(\"" ++ url ++ "\")" )


stylePosition point =
    px point.x ++ " " ++ px point.y


backgroundPosition position =
    ( "background-position", stylePosition position )
