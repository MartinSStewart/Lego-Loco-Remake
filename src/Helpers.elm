module Helpers exposing (..)


withSuffix : a -> String -> String
withSuffix value suffix =
    toString value ++ suffix


background : String -> ( String, String )
background url =
    ( "background-image", "url(\"" ++ url ++ "\")" )
