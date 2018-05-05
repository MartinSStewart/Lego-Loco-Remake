{- Auto generated code. -}


module TileType exposing (..)

import Sprite exposing (..)
import Point2 exposing (Point2)
import Model exposing (..)
import TileCategory exposing (..)


sidewalk : TileType
sidewalk =
    TileType
        (Rot1 Sprite.sidewalk)
        (Point2 1 1)
        Sprite.sidewalk
        Roads
        Basic


roadStraight : TileType
roadStraight =
    TileType
        (Rot2 Sprite.roadHorizontal Sprite.roadVertical)
        (Point2 2 2)
        Sprite.roadHorizontal
        Roads
        Basic


roadTurn : TileType
roadTurn =
    TileType
        (Rot4 Sprite.roadTurnLeftUp Sprite.roadTurnLeftDown Sprite.roadTurnRightDown Sprite.roadTurnRightUp)
        (Point2 2 2)
        Sprite.roadTurnLeftUp
        Roads
        Basic


redHouse : TileType
redHouse =
    TileType
        (Rot1 Sprite.redHouse)
        (Point2 3 3)
        Sprite.redHouseIcon
        Buildings
        Basic


railStraight : TileType
railStraight =
    TileType
        (Rot2 Sprite.railHorizontal Sprite.railVertical)
        (Point2 1 1)
        Sprite.railHorizontal
        Roads
        (Rail (\t -> Point2 1 0.5 |> Point2.rsub (Point2 0 0.5) |> Point2.rmultScalar t |> Point2.add (Point2 0 0.5)))


railTurn : TileType
railTurn =
    TileType
        (Rot4 Sprite.railTurnLeftUp Sprite.railTurnLeftDown Sprite.railTurnRightDown Sprite.railTurnRightUp)
        (Point2 3 3)
        Sprite.railTurnLeftUp
        Roads
        (Rail (\t -> Point2 (sin t) (cos t) |> Point2.rmultScalar 2.5))


railSplitRight : TileType
railSplitRight =
    TileType
        (Rot4 Sprite.railSplitHorizontalRightUpOff Sprite.railSplitVerticalLeftUpOff Sprite.railSplitHorizontalLeftDownOff Sprite.railSplitVerticalRightDownOff)
        (Point2 3 3)
        Sprite.railSplitVerticalLeftUpOff
        Roads
        (RailFork (\t -> Point2 -(sin t) (cos t) |> Point2.rmultScalar 2.5 |> Point2.add (Point2 3 0)) (\t -> Point2 3 2.5 |> Point2.rsub (Point2 0 2.5) |> Point2.rmultScalar t |> Point2.add (Point2 0 2.5)))


railSplitLeft : TileType
railSplitLeft =
    TileType
        (Rot4 Sprite.railSplitHorizontalLeftUpOff Sprite.railSplitVerticalLeftDownOff Sprite.railSplitHorizontalRightDownOff Sprite.railSplitVerticalRightUpOff)
        (Point2 3 3)
        Sprite.railSplitHorizontalLeftUpOff
        Roads
        (RailFork (\t -> Point2 (sin t) (cos t) |> Point2.rmultScalar 2.5) (\t -> Point2 3 2.5 |> Point2.rsub (Point2 0 2.5) |> Point2.rmultScalar t |> Point2.add (Point2 0 2.5)))


roadRailCrossing : TileType
roadRailCrossing =
    TileType
        (Rot2 Sprite.roadRailCrossingOpenHorizontal Sprite.roadRailCrossingOpenVertical)
        (Point2 3 2)
        Sprite.roadRailCrossingOpenHorizontal
        Roads
        (Rail (\t -> Point2 1.5 2 |> Point2.rsub (Point2 1.5 0) |> Point2.rmultScalar t |> Point2.add (Point2 1.5 0)))


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


railStraightIndex : Int
railStraightIndex =
    4


railTurnIndex : Int
railTurnIndex =
    5


railSplitRightIndex : Int
railSplitRightIndex =
    6


railSplitLeftIndex : Int
railSplitLeftIndex =
    7


roadRailCrossingIndex : Int
roadRailCrossingIndex =
    8


tiles : List TileType
tiles =
    [ sidewalk
    , roadStraight
    , roadTurn
    , redHouse
    , railStraight
    , railTurn
    , railSplitRight
    , railSplitLeft
    , roadRailCrossing
    ]
