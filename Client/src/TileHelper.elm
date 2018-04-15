module TileHelper exposing (..)

import List.Extra
import TileType exposing (..)
import Sprite exposing (..)


directions : number
directions =
    4


rotSpriteToList : TileType.RotSprite -> List Sprite
rotSpriteToList rotSprite =
    case rotSprite of
        Rot1 sprite ->
            [ sprite ]

        Rot2 horizontal vertical ->
            [ horizontal, vertical ]

        Rot4 right up left down ->
            [ right, up, left, down ]


rotSpriteGetAt : RotSprite -> Int -> Sprite
rotSpriteGetAt rotSprite index =
    let
        spriteList =
            rotSpriteToList rotSprite

        sprite =
            List.Extra.getAt (index % List.length spriteList) spriteList
    in
        case sprite of
            Just a ->
                a

            Nothing ->
                Debug.crash "There is no way this can happen."
