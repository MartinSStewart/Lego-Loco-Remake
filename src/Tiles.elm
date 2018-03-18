module Tiles exposing (..)

import Int2 exposing (Int2)


type alias Tile =
    { sprite : Sprite
    , name : String
    , gridSize : Int2
    , icon : Sprite
    }


type alias Sprite =
    { filepath : String
    , pixelSize : Int2 --Exact dimensions of image.
    , pixelOffset : Int2
    }


tiles : List Tile
tiles =
    [ Tile house0Sprite "Red House" (Int2 3 3) houseIcon0Sprite
    , defaultTile
    ]


defaultTile : Tile
defaultTile =
    Tile sidewalkSprite "Sidewalk" (Int2 1 1) sidewalkSprite


sidewalkSprite : Sprite
sidewalkSprite =
    Sprite "/sidewalk.png" (Int2 16 16) Int2.zero


house0Sprite : Sprite
house0Sprite =
    Sprite "/house0.png" (Int2 48 58) (Int2 0 -10)


houseIcon0Sprite : Sprite
houseIcon0Sprite =
    Sprite "/houseIcon0.png" (Int2 44 41) Int2.zero
