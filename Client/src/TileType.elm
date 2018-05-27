{- Auto generated code. -}


module TileType exposing (..)

import Sprite exposing (..)
import Point2 exposing (Point2)
import Model exposing (..)
import TileCategory exposing (..)


sidewalk : TileType
sidewalk =
    TileType (Point2 1 1) Sprite.sidewalk Roads (Basic (Rot1 Sprite.sidewalk))


roadStraight : TileType
roadStraight =
    TileType 
        (Point2 2 2)
        Sprite.roadHorizontal
        Roads
        (Basic (Rot2 Sprite.roadHorizontal Sprite.roadVertical))


roadTurn : TileType
roadTurn =
    TileType 
        (Point2 2 2)
        Sprite.roadTurnLeftUp
        Roads
        (Basic (Rot4 Sprite.roadTurnLeftUp Sprite.roadTurnLeftDown Sprite.roadTurnRightDown Sprite.roadTurnRightUp))


redHouse : TileType
redHouse =
    TileType 
        (Point2 3 3)
        Sprite.redHouseIcon
        Buildings
        (Basic (Rot1 Sprite.redHouse))


railStraight : TileType
railStraight =
    TileType 
        (Point2 1 1)
        Sprite.railHorizontal
        Roads
        (Rail
            (Rot2 Sprite.railHorizontal Sprite.railVertical)
            (\t -> Point2 1 0.5 |> Point2.rsub (Point2 0 0.5) |> Point2.rmultScalar t |> Point2.add (Point2 0 0.5))
        )


railTurn : TileType
railTurn =
    TileType 
        (Point2 3 3)
        Sprite.railTurnLeftUp
        Roads
        (Rail
            (Rot4 Sprite.railTurnLeftUp Sprite.railTurnLeftDown Sprite.railTurnRightDown Sprite.railTurnRightUp)
            (\t -> Point2 (sin (t * pi / 2)) (cos (t * pi / 2)) |> Point2.rmultScalar 2.5)
        )


railSplitRight : TileType
railSplitRight =
    TileType 
        (Point2 3 3)
        Sprite.railSplitVerticalLeftUpOff
        Roads
        (RailFork
            (Rot4 ( Sprite.railSplitHorizontalRightUpOn, Sprite.railSplitHorizontalRightUpOff ) ( Sprite.railSplitVerticalLeftUpOn, Sprite.railSplitVerticalLeftUpOff ) ( Sprite.railSplitHorizontalLeftDownOn, Sprite.railSplitHorizontalLeftDownOff ) ( Sprite.railSplitVerticalRightDownOn, Sprite.railSplitVerticalRightDownOff ))
            (\t -> Point2 -(sin (t * pi / 2)) (cos (t * pi / 2)) |> Point2.rmultScalar 2.5 |> Point2.add (Point2 3 0))
            (\t -> Point2 3 2.5 |> Point2.rsub (Point2 0 2.5) |> Point2.rmultScalar t |> Point2.add (Point2 0 2.5))
        )


railSplitLeft : TileType
railSplitLeft =
    TileType 
        (Point2 3 3)
        Sprite.railSplitHorizontalLeftUpOff
        Roads
        (RailFork
            (Rot4 ( Sprite.railSplitHorizontalLeftUpOn, Sprite.railSplitHorizontalLeftUpOff ) ( Sprite.railSplitVerticalLeftDownOn, Sprite.railSplitVerticalLeftDownOff ) ( Sprite.railSplitHorizontalRightDownOn, Sprite.railSplitHorizontalRightDownOff ) ( Sprite.railSplitVerticalRightUpOn, Sprite.railSplitVerticalRightUpOff ))
            (\t -> Point2 (sin (t * pi / 2)) (cos (t * pi / 2)) |> Point2.rmultScalar 2.5)
            (\t -> Point2 3 2.5 |> Point2.rsub (Point2 0 2.5) |> Point2.rmultScalar t |> Point2.add (Point2 0 2.5))
        )


roadRailCrossing : TileType
roadRailCrossing =
    TileType 
        (Point2 3 2)
        Sprite.roadRailCrossingOpenHorizontal
        Roads
        (Rail
            (Rot2 Sprite.roadRailCrossingOpenHorizontal Sprite.roadRailCrossingOpenVertical)
            (\t -> Point2 1.5 2 |> Point2.rsub (Point2 1.5 0) |> Point2.rmultScalar t |> Point2.add (Point2 1.5 0))
        )


depot : TileType
depot =
    TileType 
        (Point2 5 3)
        Sprite.depotLeftOccupied
        Roads
        (Depot
            (Rot4 ( Sprite.depotLeftOccupied, Sprite.depotLeftOccupied, Sprite.depotLeftOccupied ) ( Sprite.depotDownOccupied, Sprite.depotDownOpen, Sprite.depotDownClosed ) ( Sprite.depotRightOccupied, Sprite.depotRightOpen, Sprite.depotRightClosed ) ( Sprite.depotUpOccupied, Sprite.depotUpOpen, Sprite.depotUpClosed ))
            (\t -> Point2 4 1.5 |> Point2.rsub (Point2 0 1.5) |> Point2.rmultScalar t |> Point2.add (Point2 0 1.5))
        )


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


depotId : Model.TileTypeId
depotId =
    Model.TileTypeId 9


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
    , depot
    ]