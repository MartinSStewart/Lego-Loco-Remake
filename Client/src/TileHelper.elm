module TileHelper exposing (..)

import List.Extra
import Model exposing (..)


directions : number
directions =
    4


rotToList : Rot a -> List a
rotToList rotSprite =
    case rotSprite of
        Rot1 single ->
            [ single ]

        Rot2 horizontal vertical ->
            [ horizontal, vertical ]

        Rot4 right up left down ->
            [ right, up, left, down ]


rotGetAt : Rot a -> Int -> a
rotGetAt rotSprite index =
    let
        spriteList =
            rotToList rotSprite

        sprite =
            List.Extra.getAt (index % List.length spriteList) spriteList
    in
        case sprite of
            Just a ->
                a

            Nothing ->
                Debug.crash "There is no way this can happen."
