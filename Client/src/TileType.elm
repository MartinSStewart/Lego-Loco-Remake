{- Auto generated code. -}


module TileType exposing (..)

import Sprite exposing (..)
import Point2 exposing (Point2)
import Model exposing (..)
import TileCategory exposing (..)


sidewalk : TileType
sidewalk =
    TileType (Rot1 Sprite.sidewalk) (Point2 1 1) Sprite.sidewalk Roads


roadStraight : TileType
roadStraight =
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


railStraight : TileType
railStraight =
    TileType (Rot2 Sprite.railHorizontal Sprite.railVertical) (Point2 1 1) Sprite.railHorizontal Roads


railTurn : TileType
railTurn =
    TileType (Rot4 Sprite.railTurnLeftUp Sprite.railTurnLeftDown Sprite.railTurnRightDown Sprite.railTurnRightUp) (Point2 3 3) Sprite.railTurnLeftUp Roads


railSplitRight : TileType
railSplitRight =
    TileType (Rot4 Sprite.railSplitVerticalLeftUpOff Sprite.railSplitHorizontalLeftDownOff Sprite.railSplitVerticalRightDownOff Sprite.railSplitHorizontalRightUpOff) (Point2 3 3) Sprite.railSplitVerticalLeftUpOff Roads


railSplitLeft : TileType
railSplitLeft =
    TileType (Rot4 Sprite.railSplitHorizontalLeftUpOff Sprite.railSplitVerticalLeftDownOff Sprite.railSplitHorizontalRightDownOff Sprite.railSplitVerticalRightUpOff) (Point2 3 3) Sprite.railSplitHorizontalLeftUpOff Roads


sidewalkIndex : Int
sidewalkIndex =
    0


roadStraightIndex : Int
roadStraightIndex =
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


railStraightIndex : Int
railStraightIndex =
    5


railTurnIndex : Int
railTurnIndex =
    6


railSplitRightIndex : Int
railSplitRightIndex =
    7


railSplitLeftIndex : Int
railSplitLeftIndex =
    8


tiles : List TileType
tiles = 
    [ sidewalk
    , roadStraight
    , roadTurn
    , redHouse
    , roadRailCrossing
    , railStraight
    , railTurn
    , railSplitRight
    , railSplitLeft
    ]