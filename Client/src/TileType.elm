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


sidewalkId : Model.TileTypeId
sidewalkId =
    Model.TileTypeId 0


roadStraightId : Model.TileTypeId
roadStraightId =
    Model.TileTypeId 1


roadTurnId : Model.TileTypeId
roadTurnId =
    Model.TileTypeId 2


redHouseId : Model.TileTypeId
redHouseId =
    Model.TileTypeId 3


railStraightId : Model.TileTypeId
railStraightId =
    Model.TileTypeId 4


railTurnId : Model.TileTypeId
railTurnId =
    Model.TileTypeId 5


railSplitRightId : Model.TileTypeId
railSplitRightId =
    Model.TileTypeId 6


railSplitLeftId : Model.TileTypeId
railSplitLeftId =
    Model.TileTypeId 7


roadRailCrossingId : Model.TileTypeId
roadRailCrossingId =
    Model.TileTypeId 8


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