using Common;
using Common.TileData;
using Common.TileTypeData;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public static class TrainHelper
    {
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

        private static (Tile Tile, bool AtEndOfPath)? GetNextPath(this World world, Tile tile, bool atEndOfPath)
        {
            var path = world.GetGridPath(tile);
            var pos = atEndOfPath ? path(1) : path(0);
            var superGridPos = World.GridToSuperGrid(tile.BaseData.GridPosition);

            var tiles = World.GetPointNeighbors(superGridPos)
                .SelectMany(item => world.GetTiles(item))
                .Where(item => item.BaseData != tile.BaseData)
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

        private static IRailTileData ModifyTrains(IRailTileData tileData, Func<ImmutableList<Train>, ImmutableList<Train>> trainFunc)
        {
            switch (tileData)
            {
                case TileRail rail:
                    return new TileRail(trainFunc(rail.Trains));
                case TileRailFork railFork:
                    return new TileRailFork(trainFunc(railFork.Trains), railFork.IsOn);
                case TileDepot depot:
                    return new TileDepot(trainFunc(depot.Trains), depot.Occupied);
                default:
                    throw new NotImplementedException();
            }
        }

        public static void MoveTrains(this World world, TimeSpan stepSize)
        {
            var substepSize = TimeSpan.FromMilliseconds(33);

            void Move(Tile tile, Train train)
            {
                var (nextTile, newTrain) = world._move(tile, train, train.Speed * substepSize.TotalSeconds * (train.FacingEnd ? 1 : -1));

                world.ModifyTileData(tile.BaseData, data => ModifyTrains((IRailTileData)data, trains => trains.Remove(train)));
                world.ModifyTileData(nextTile.BaseData, data => ModifyTrains((IRailTileData)data, trains => trains.Add(newTrain)));
            }

            var iterations = stepSize.Ticks / substepSize.Ticks;
            while (iterations > 0)
            {
                foreach (var tile in world.RailTiles.ToList())
                {
                    if (tile.Data is IRailTileData railData)
                    {
                        foreach (var train in railData.Trains)
                        {
                            Move(tile, train);
                        }
                    }
                    else
                    {
                        DebugEx.Fail($"Only rail tiles should be in {nameof(world.RailTiles)} list.");
                    }
                }
                iterations--;
            }
        }

        public static Double2? GetTrainPosition(this World world, int trainId)
        {
            foreach (var item in world.RailTiles)
            {
                var train = ((IRailTileData)item.Data).Trains.SingleOrDefault(trainItem => trainItem.Id == trainId);
                if (train != null)
                {
                    var path = GetGridPath(world, item);
                    return path(train.T);
                }
            }
            return null;
        }
    }
}
