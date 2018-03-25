module Tiles exposing (..)

import Int2 exposing (Int2)
import List.Extra


type alias TileType =
    { sprite : RotSprite
    , name : String
    , gridSize : Int2
    , icon : Sprite
    }


type alias Sprite =
    { filepath : String
    , pixelSize : Int2 --Exact dimensions of image.
    , pixelOffset : Int2
    }


type RotSprite
    = Rot1 Sprite
    | Rot2 Sprite Sprite
    | Rot4 Sprite Sprite Sprite Sprite


directions : number
directions =
    4


rotSpriteToList : RotSprite -> List Sprite
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


tiles : List TileType
tiles =
    [ TileType (Rot1 house0Sprite) "Red House" (Int2 3 3) houseIcon0Sprite
    , defaultTile
    , TileType (Rot2 roadHorizontalSprite roadVerticalSprite) "Road" (Int2 2 2) roadHorizontalSprite
    , TileType (Rot4 roadTurnLeftDown roadTurnRightDown roadTurnRightUp roadTurnLeftUp) "Road Turn" (Int2 2 2) roadTurnLeftUp
    ]


defaultTile : TileType
defaultTile =
    TileType (Rot1 sidewalkSprite) "Sidewalk" (Int2 1 1) sidewalkSprite


sidewalkSprite : Sprite
sidewalkSprite =
    Sprite "/sidewalk.png" (Int2 16 16) Int2.zero


house0Sprite : Sprite
house0Sprite =
    Sprite "/house0.png" (Int2 48 58) (Int2 0 -10)


houseIcon0Sprite : Sprite
houseIcon0Sprite =
    Sprite "/houseIcon0.png" (Int2 44 41) Int2.zero


roadVerticalSprite : Sprite
roadVerticalSprite =
    Sprite "/roadVertical.png" (Int2 32 32) Int2.zero


roadHorizontalSprite : Sprite
roadHorizontalSprite =
    Sprite "/roadHorizontal.png" (Int2 32 32) Int2.zero


roadTurnLeftUp : Sprite
roadTurnLeftUp =
    Sprite "/roadTurnLeftUp.png" (Int2 32 32) Int2.zero


roadTurnLeftDown : Sprite
roadTurnLeftDown =
    Sprite "/roadTurnLeftDown.png" (Int2 32 32) Int2.zero


roadTurnRightUp : Sprite
roadTurnRightUp =
    Sprite "/roadTurnRightUp.png" (Int2 32 32) Int2.zero


roadTurnRightDown : Sprite
roadTurnRightDown =
    Sprite "/roadTurnRightDown.png" (Int2 32 32) Int2.zero
