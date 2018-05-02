{- Auto generated code. -}


module TileType exposing (..)

import Point2 exposing (Point2)
import Sprite exposing (Sprite)


type alias TileType =
    { sprite : RotSprite
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
    TileType (Rot1 Sprite.sidewalk) (Point2 1 1) Sprite.sidewalk Roads


straightRoad : TileType
straightRoad =
    TileType (Rot2 Sprite.roadHorizontal Sprite.roadVertical) (Point2 2 2) Sprite.roadHorizontal Roads


roadTurn : TileType
roadTurn =
    TileType (Rot4 Sprite.roadTurnLeftUp Sprite.roadTurnLeftDown Sprite.roadTurnRightDown Sprite.roadTurnRightUp) (Point2 2 2) Sprite.roadTurnLeftUp Roads


redHouse : TileType
redHouse =
    TileType (Rot1 Sprite.redHouse) (Point2 3 3) Sprite.redHouseIcon Buildings


roadRailCrossing : TileType
roadRailCrossing =
    TileType (Rot2 Sprite.roadRailCrossingOpenHorizontal Sprite.roadRailCrossingOpenVertical) (Point2 3 2) Sprite.roadRailCrossingOpenHorizontal Roads


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


roadRailCrossingIndex : Int
roadRailCrossingIndex =
    4


tiles : List TileType
tiles = 
    [ sidewalk
    , straightRoad
    , roadTurn
    , redHouse
    , roadRailCrossing
    ]