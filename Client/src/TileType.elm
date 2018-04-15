{- Auto generated code. -}


module TileType exposing (..)

import Int2 exposing (Int2)
import Sprite exposing (Sprite)


type alias TileType =
    { sprite : RotSprite
    , name : String
    , gridSize : Int2
    , icon : Sprite
    }


type RotSprite
    = Rot1 Sprite
    | Rot2 Sprite Sprite
    | Rot4 Sprite Sprite Sprite Sprite


sidewalk : TileType
sidewalk =
    TileType (Rot1 Sprite.sidewalk) "Sidewalk" (Int2 1 1) Sprite.sidewalk


straightRoad : TileType
straightRoad =
    TileType (Rot2 Sprite.roadHorizontal Sprite.roadVertical) "Straight Road" (Int2 2 2) Sprite.roadHorizontal


roadTurn : TileType
roadTurn =
    TileType (Rot4 Sprite.roadTurnLeftUp Sprite.roadTurnLeftDown Sprite.roadTurnRightDown Sprite.roadTurnRightUp) "Road Turn" (Int2 2 2) Sprite.roadTurnLeftUp


redHouse : TileType
redHouse =
    TileType (Rot1 Sprite.redHouse) "Red House" (Int2 3 3) Sprite.redHouseIcon


sidewalkIndex : Int
sidewalkIndex =
    0


straightRoadIndex : Int
straightRoadIndex =
    1


roadTurnIndex : Int
roadTurnIndex =
    2


redHouseIndex : Int
redHouseIndex =
    3


tiles : List TileType
tiles =
    [ sidewalk
    , straightRoad
    , roadTurn
    , redHouse
    ]
