module TrainTests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (int, list)
import TrainHelper exposing (..)
import Grid
import Tile
import TileType
import Point2 exposing (Point2)
import Model exposing (..)


railTile : Tile
railTile =
    Tile
        (TileBaseData TileType.railStraightId Point2.zero 0)
        (TileRail [ Train 0 1 True (TrainId 0) ])


all : Test
all =
    describe "Train movement tests"
        [ fuzz (Fuzz.floatRange 0 1) "Move on path" <|
            \movement ->
                let
                    ( t, movementLeft ) =
                        moveOnPath (\t -> Point2 t 0) 0 movement
                in
                    Expect.all
                        [ (\_ -> Expect.equal 0 movementLeft)
                        , (\_ -> Expect.within (Expect.AbsoluteOrRelative 0.1 0.1) movement t)
                        ]
                        ()
        , test "Move past end of path" <|
            \_ ->
                let
                    ( t, movementLeft ) =
                        moveOnPath (\t -> Point2 t 0) 0 2
                in
                    Expect.all
                        [ (\_ -> Expect.equal 1 t)
                        , (\_ -> Expect.within (Expect.AbsoluteOrRelative 0.1 0.1) 1 movementLeft)
                        ]
                        ()
        , fuzz (Fuzz.floatRange -1 0) "Move backwards on path" <|
            \movement ->
                let
                    ( t, movementLeft ) =
                        moveOnPath (\t -> Point2 t 0) 1 movement
                in
                    Expect.all
                        [ (\_ -> Expect.equal 0 movementLeft)
                        , (\_ -> Expect.within (Expect.AbsoluteOrRelative 0.1 0.1) (1 + movement) t)
                        ]
                        ()
        , test "Train moves forward" <|
            \_ ->
                trainMovesForward
        , test "Train moves to next rail" <|
            (\_ -> trainMovesToNextRail)
        , test "Get train tiles" <|
            \_ ->
                Grid.init
                    |> Grid.addTile railTile
                    |> Grid.getTrainTiles
                    |> Expect.equal [ railTile ]
        , test "Substep" <|
            \_ ->
                substepTest
        , test "Move from turn to straight" <|
            \_ ->
                moveFromTurnToStraight
        ]


trainMovesForward : Expect.Expectation
trainMovesForward =
    let
        grid =
            Grid.init |> Grid.addTile railTile

        expected =
            TileRail [ Train 1 1 True (TrainId 0) ]
    in
        moveTrains 1000 grid
            |> .get (Grid.getSetAt Point2.zero)
            |> List.head
            |> Maybe.map .data
            |> Expect.equal (Just expected)


moveFromTurnToStraight : Expect.Expectation
moveFromTurnToStraight =
    let
        turnRail =
            Tile
                (TileBaseData TileType.railTurnId Point2.zero 0)
                (TileRail [ Train 0 3 True (TrainId 0) ])

        nextRail =
            Tile.initTile
                (TileBaseData TileType.railStraightId (Point2 2 -1) 1)

        grid =
            Grid.init
                |> Grid.addTile turnRail
                |> Grid.addTile nextRail

        expectedRail =
            { nextRail | data = (TileRail [ Train 1 3 True (TrainId 0) ]) }
    in
        moveTrains 1000 grid
            |> Grid.getTrainTiles
            |> Expect.equal [ expectedRail ]


substepTest : Expect.Expectation
substepTest =
    let
        nextRail =
            Tile.initTile (TileBaseData TileType.railStraightId (Point2 1 0) 0)

        grid =
            Grid.init |> Grid.addTile railTile |> Grid.addTile nextRail
    in
        moveSubstep grid railTile (Train 0 1 True (TrainId 0)) 2
            |> Expect.equal ( nextRail, (Train 1 1 True (TrainId 0)) )


trainMovesToNextRail : Expect.Expectation
trainMovesToNextRail =
    let
        nextRail =
            Tile.initTile (TileBaseData TileType.railStraightId (Point2 1 0) 0)

        grid =
            Grid.init |> Grid.addTile railTile |> Grid.addTile nextRail

        expectedRail =
            Tile
                (TileBaseData TileType.railStraightId (Point2 1 0) 0)
                (TileRail [ Train 1 1 True (TrainId 0) ])

        expectedGrid =
            Grid.init |> Grid.addTile expectedRail
    in
        moveTrains 2000 grid
            |> Grid.getTrainTiles
            |> Expect.equal [ expectedRail ]
