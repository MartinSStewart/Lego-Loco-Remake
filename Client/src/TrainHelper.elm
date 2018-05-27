module TrainHelper exposing (..)

import Grid
import Helpers exposing (ifThenElse, print)
import List.Extra
import List.FlatMap as FlatMap
import Maybe.Extra
import Model exposing (..)
import Point2 exposing (Point2)
import Tile


{-
   private static Func<double, Double2> GetPath(this World world, Tile tile)
   {
       var tileType = world.TileTypes[tile.BaseData.TileTypeId];
       switch (tileType.Data)
       {
           case Rail rail:
               return rail.Path.Func;
           case RailFork railFork:
               var tileRailFork = tile.Data as TileRailFork;
               return tileRailFork.IsOn
                   ? railFork.PathOn.Func
                   : railFork.PathOff.Func;
           case Depot depot:
               return depot.Path.Func;
           default:
               return null;
       }
   }
-}


getPath : Tile -> Maybe (Float -> Point2 Float)
getPath tile =
    case Tile.getTileTypeByTile tile.baseData |> .data of
        Basic _ ->
            Nothing

        Model.Rail _ path ->
            Just path

        Model.RailFork _ pathOn pathOff ->
            case tile.data of
                TileRailFork trainList isOn ->
                    ifThenElse isOn pathOn pathOff |> Just

                _ ->
                    Debug.crash "Tile can't have this data type." Nothing

        Model.Depot _ path ->
            Just path



{-
   /// <summary>
   /// Returns a tile path in grid coordinates.
   /// </summary>
   /// <returns></returns>
   public static Func<double, Double2> GetGridPath(this World world, Tile tile)
   {
       var path = GetPath(world, tile);
       if (path == null)
       {
           return null;
       }

       var tileType = world.TileTypes[tile.BaseData.TileTypeId];
       var size = tileType.GridSize;

       var halfSize = size.ToDouble2() / 2;
       var halfSizeRotated = world.GetTileSize(tile).ToDouble2() / 2;
       return t => (path(t) - halfSize).RotateBy90(tile.BaseData.Rotation) + halfSizeRotated + tile.BaseData.GridPosition.ToDouble2();
   }
-}


getGridPath : Tile -> Maybe (Float -> Point2 Float)
getGridPath tile =
    getPath tile |> Maybe.map (Tile.pathToGridPath tile)



{-
   private static (double T, double MovementLeft) MoveOnPath(Func<double, Double2> path, double t, double movementLeft)
   {
       var moveSign = movementLeft > 0 ? 1 : -1;

       var posPrev = path(t);
       var newT = t + 0.01 * moveSign;
       var pos = path(newT);
       var newMovementLeft = movementLeft - (pos - posPrev).Length * moveSign;
       if (t > 1 && movementLeft > 0)
       {
           return (1, Math.Max(newMovementLeft, 0));
       }
       if (t < 0 && movementLeft < 0)
       {
           return (0, Math.Min(newMovementLeft, 0));
       }
       if (Math.Sign(newMovementLeft) != Math.Sign(movementLeft))
       {
           return (t, 0);
       }
       return MoveOnPath(path, newT, newMovementLeft);
   }
-}


sign : Float -> Int
sign value =
    if value > 0 then
        1
    else if value < 0 then
        -1
    else
        0


moveOnPath : (Float -> Point2 Float) -> Float -> Float -> ( Float, Float )
moveOnPath path t movementLeft =
    let
        moveSign =
            ifThenElse (movementLeft > 0) 1 -1

        posPrev =
            path t

        newT =
            t + 0.01 * moveSign

        pos =
            path newT

        newMovementLeft =
            movementLeft - (Point2.sub pos posPrev |> Point2.length) * moveSign
    in
        if t > 1 && movementLeft > 0 then
            ( 1, max newMovementLeft 0 )
        else if t < 0 && movementLeft < 0 then
            ( 0, min newMovementLeft 0 )
        else if sign newMovementLeft /= sign movementLeft then
            ( t, 0 )
        else
            moveOnPath path newT newMovementLeft



{-
   private static (Tile Tile, bool AtEndOfPath)? GetNextPath(this World world, Tile tile, bool atEndOfPath)
   {
       var path = world.GetGridPath(tile);
       var pos = atEndOfPath ? path(1) : path(0);
       var superGridPos = World.GridToSuperGrid(tile.BaseData.GridPosition);

       var tiles = World.GetPointNeighbors(superGridPos)
           .SelectMany(item => world.GetTiles(item))
           .Where(item => item != tile)
           .ToList();

       var nextTiles = tiles
           .Select(item =>
           {
               (Tile, bool)? NextPath(Tile tileItem)
               {
                   var otherPath = world.GetGridPath(tileItem);
                   if (otherPath == null)
                   {
                       return null;
                   }

                   if ((pos - otherPath(0)).Length < 0.1)
                   {
                       return (tileItem, false);
                   }

                   if ((pos - otherPath(1)).Length < 0.1)
                   {
                       return (tileItem, true);
                   }
                   return null;
               }

               var result = NextPath(item);
               if (result == null &&
                   item.Data is TileRailFork railFork &&
                   railFork.Trains.Count == 0)
               {
                   return NextPath(item.With(data: new TileRailFork(railFork.Trains, !railFork.IsOn)));
               }
               return result;

           }).ToList();

       return nextTiles
           .SingleOrDefault(item => item != null);
   }
-}


getNextPath : Grid -> Tile -> Bool -> Maybe ( Tile, Bool )
getNextPath grid tile atEndOfPath =
    getGridPath tile
        |> Maybe.andThen
            (\path ->
                let
                    pos =
                        ifThenElse atEndOfPath 1 0 |> path

                    superGridPos =
                        Grid.gridPosToSuperPos tile.baseData.position

                    pointMatches =
                        Point2.sub pos >> Point2.length >> (>) 0.1

                    nextPath tileItem =
                        getGridPath tileItem
                            |> Maybe.andThen
                                (\otherPath ->
                                    if pointMatches (otherPath 0) then
                                        Just ( tileItem, False )
                                    else if pointMatches (otherPath 1) then
                                        Just ( tileItem, True )
                                    else
                                        Nothing
                                )
                in
                    Grid.neighborPoints superGridPos
                        |> FlatMap.flatMap (\superPos -> .get (Grid.getSetAt superPos) grid)
                        |> List.filter ((/=) tile)
                        |> List.map
                            (\otherTile ->
                                otherTile
                                    |> nextPath
                                    |> or
                                        (case otherTile.data of
                                            TileRailFork trains isOn ->
                                                nextPath { otherTile | data = TileRailFork trains (not isOn) }

                                            _ ->
                                                Nothing
                                        )
                            )
                        |> List.Extra.find ((/=) Nothing)
                        |> Maybe.Extra.join
            )


{-| Returns otherValue if value is Nothing.
-}
or : Maybe a -> Maybe a -> Maybe a
or otherValue value =
    ifThenElse (value == Nothing) otherValue value



{-
   private static (Tile, Train) _move(this World world, Tile tile, Train train, double movementLeft)
   {
       DebugEx.Assert(train.T >= 0 && train.T <= 1);
       var path = world.GetPath(tile);
       var (t, newMovementLeft) = MoveOnPath(path, train.T, movementLeft);
       if (newMovementLeft != 0)
       {
           var nextPath = world.GetNextPath(tile, t == 1);
           if (nextPath != null)
           {
               var nextTile = nextPath?.Tile;
               var endOfNextPath = nextPath?.AtEndOfPath ?? false;

               var flip = train.FacingEnd == endOfNextPath;

               DebugEx.Assert(world.ModifyTileData(nextTile.BaseData, _ => nextTile.Data), "Tile could not be found.");

               return world._move(
                   nextTile,
                   new Train(endOfNextPath ? 1 : 0, train.Speed, flip ? !train.FacingEnd : train.FacingEnd, train.Id),
                   flip ? -newMovementLeft : newMovementLeft);
           }
       }
       return (tile, new Train(t, train.Speed, train.FacingEnd, train.Id));
   }

-}


moveSubstep : Grid -> Tile -> Train -> Float -> ( Tile, Train )
moveSubstep grid tile train movementLeft =
    getPath tile
        |> Maybe.map
            (\path ->
                let
                    ( t, newMovementLeft ) =
                        moveOnPath path train.t movementLeft
                in
                    if newMovementLeft /= 0 then
                        case getNextPath grid tile (t == 1) of
                            Just ( nextTile, atEndOfPath ) ->
                                let
                                    flip =
                                        train.facingEnd == atEndOfPath

                                    nextTrain =
                                        Train
                                            (ifThenElse atEndOfPath 1 0)
                                            train.speed
                                            (ifThenElse flip (not train.facingEnd) train.facingEnd)
                                            train.id
                                in
                                    moveSubstep
                                        grid
                                        nextTile
                                        nextTrain
                                        (ifThenElse flip -newMovementLeft newMovementLeft)

                            Nothing ->
                                ( tile, Train t train.speed train.facingEnd train.id )
                    else
                        ( tile, Train t train.speed train.facingEnd train.id )
            )
        |> Maybe.withDefault ( tile, train )


moveTrains : Int -> Grid -> Grid
moveTrains millisecondStepSize grid =
    let
        substepSize =
            16

        move tile train grid =
            let
                movementLeft =
                    train.speed * (toFloat substepSize / 1000) * (ifThenElse train.facingEnd 1 -1)

                ( nextTile, newTrain ) =
                    moveSubstep grid tile train movementLeft
            in
                grid
                    |> Grid.modifyTileData
                        tile.baseData
                        (modifyTrains (List.filter ((/=) train)))
                    |> Grid.modifyTileData
                        nextTile.baseData
                        (modifyTrains ((::) newTrain))

        substep iterationsLeft grid =
            if iterationsLeft == 0 then
                grid
            else
                Grid.getTrainTiles grid
                    |> List.foldl
                        (\trainTile newGrid ->
                            getTrains trainTile.data
                                |> List.foldl
                                    (\train newNewGrid -> move trainTile train newNewGrid)
                                    newGrid
                        )
                        grid
                    |> substep (iterationsLeft - 1)
    in
        substep (millisecondStepSize // substepSize) grid


modifyTrains : (List Train -> List Train) -> TileData -> TileData
modifyTrains trainFunc tileData =
    case tileData of
        TileBasic ->
            tileData

        TileRail trainList ->
            TileRail (trainFunc trainList)

        TileRailFork trainList isOn ->
            TileRailFork (trainFunc trainList) isOn

        TileDepot trainList isOccupied ->
            TileDepot (trainFunc trainList) isOccupied


getTrains : TileData -> List Train
getTrains tile =
    case tile of
        TileBasic ->
            []

        Model.TileRail trains ->
            trains

        Model.TileRailFork trains _ ->
            trains

        Model.TileDepot trains _ ->
            trains
