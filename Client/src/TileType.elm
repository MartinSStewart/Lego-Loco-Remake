{- Auto generated code. -}


module TileType exposing (..)

import Point2 exposing (Point2)
import Sprite exposing (Sprite)


type alias TileType =
    { sprite : RotSprite
    , name : String
    , gridSize : Point2 Int
    , icon : Sprite
    , category : Category
    }


type RotSprite
    = Rot1 Sprite
    | Rot2 Sprite Sprite
    | Rot4 Sprite Sprite Sprite Sprite


type Category
    = Buildings
    | Nature
    | Roads


sidewalk : TileType
sidewalk =
    TileType (Rot1 Sprite.sidewalk) "Sidewalk" (Point2 1 1) Sprite.sidewalk Roads


straightRoad : TileType
straightRoad =
    TileType (Rot2 Sprite.roadHorizontal Sprite.roadVertical) "Straight Road" (Point2 2 2) Sprite.roadHorizontal Roads


roadTurn : TileType
roadTurn =
    TileType (Rot4 Sprite.roadTurnLeftUp Sprite.roadTurnLeftDown Sprite.roadTurnRightDown Sprite.roadTurnRightUp) "Road Turn" (Point2 2 2) Sprite.roadTurnLeftUp Roads


redHouse : TileType
redHouse =
    TileType (Rot1 Sprite.redHouse) "Red House" (Point2 3 3) Sprite.redHouseIcon Buildings


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
