﻿using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MoreLinq;
using Common;
using Common.TileData;
using Newtonsoft.Json;
using Common.TileTypeData;

namespace Server
{
    public class World
    {
        public static Int2 MinGridPosition { get; } = new Int2(-1000000, -1000000);
        public static Int2 MaxGridPosition { get; } = new Int2(1000000, 1000000);

        /// <summary>
        /// This value must be larger than all tile type grid sizes.
        /// </summary>
        public const int SuperGridSize = 16;

        public int TileCount => _superGrid.Values.SelectMany(item => item).Count();

        public ImmutableList<TileType> TileTypes { get; }

        private readonly MultiValueDictionary<Int2, Tile> _superGrid = new MultiValueDictionary<Int2, Tile>();
        public readonly HashSet<Tile> RailTiles = new HashSet<Tile>();

        public World(ImmutableList<TileType> tileTypes)
        {
            TileTypes = tileTypes;
        }

        public static World Load(ImmutableList<TileType> tileTypes, string json)
        {
            var world = new World(tileTypes);
            var tiles = JsonConvert.DeserializeObject<Tile[]>(
                json, 
                new JsonSerializerSettings
                {
                    TypeNameHandling = TypeNameHandling.Auto
                });
            foreach (var tile in tiles)
            {
                world.FastAddTile(tile);
            }
            return world;
        }

        public string Save() => 
            JsonConvert.SerializeObject(
                _superGrid.Values.SelectMany(item => item).ToArray(), 
                new JsonSerializerSettings
                {
                    TypeNameHandling = TypeNameHandling.Auto
                });

        public IEnumerable<Tile> GetTiles(Int2 superGridPosition) =>
            _superGrid.TryGetValue(superGridPosition, out IReadOnlyCollection<Tile> value)
                ? value
                : new Tile[0];

        public static Int2 GridToSuperGrid(Int2 gridPosition) =>
            new Int2(
                gridPosition.X / SuperGridSize - (gridPosition.X < 0 ? 1 : 0),
                gridPosition.Y / SuperGridSize - (gridPosition.Y < 0 ? 1 : 0));

        public void AddTile(Tile tile)
        {
            if (!PointInRectangle(MinGridPosition, MaxGridPosition - MinGridPosition, tile.BaseData.GridPosition))
            {
                return;
            }

            var tileType = TileTypes[tile.BaseData.TileTypeId];
            var gridPos = tile.BaseData.GridPosition;
            var superGridPos = GridToSuperGrid(gridPos);

            var superGridTiles = GetPointNeighbors(superGridPos).Select(item => (item, GetTiles(item).ToArray()));

            foreach (var (pos, tiles) in superGridTiles)
            {
                foreach (var otherTile in tiles.Where(item => TilesOverlap(tile, item)))
                {
                    var result = _superGrid.Remove(pos, otherTile);
                    DebugEx.Assert(result, "We should be able to remove the tile from the place we just found it in.");
                }
            }

            FastAddTile(tile);
        }

        public static IEnumerable<Int2> GetPointNeighbors(Int2 point) =>
            new[]
            {
                new Int2(-1, -1), new Int2(0, -1), new Int2(1, -1),
                new Int2(-1, 0), new Int2(0, 0), new Int2(1, 0),
                new Int2(-1, 1), new Int2(0, 1), new Int2(1, 1),
            }.Select(item => item + point);

        /// <summary>
        /// Adds a tile without any collision checks or bounds checks.
        /// </summary>
        /// <param name="tile"></param>
        public void FastAddTile(Tile tile)
        {
            var superGridPos = GridToSuperGrid(tile.BaseData.GridPosition);
            _superGrid.Add(superGridPos, tile);
            if (tile.Data is IRailTileData railTile && railTile.Trains.Any())
            {
                RailTiles.Add(tile);
            }
        }

        /// <summary>
        /// Clicks a tile. Returns whether a tile was present to be clicked on.
        /// </summary>
        /// <param name="tile"></param>
        /// <returns></returns>
        public bool ClickTile(TileBaseData tileBaseData)
        {
            var tile = GetTile(tileBaseData);
            if (tile == null)
            {
                return false;
            }

            switch (tile.Data)
            {
                case TileBasic _:
                    break;
                case TileRail _:
                    break;
                case TileRailFork fork:
                    ReplaceTileData(tile.BaseData, new TileRailFork(fork.Trains, !fork.IsOn));
                    break;
                case TileDepot depot:
                    break;
                default:
                    throw new NotImplementedException();
            }

            return true;
        }

        public void AddTile(string tileTypeName, Int2 gridPosition, int rotation = 0) =>
            AddTile(CreateFromName(tileTypeName, gridPosition, rotation));

        public bool ReplaceTileData(TileBaseData tileBaseData, ITileData newTileData)
        {
            if (Remove(tileBaseData))
            {
                FastAddTile(new Tile(tileBaseData, newTileData));
                return true;
            }
            return false;
        }

        public bool ModifyTileData(TileBaseData tileBaseData, Func<ITileData, ITileData> modifyTileData)
        {
            var oldTile = GetTile(tileBaseData);
            if (Remove(tileBaseData))
            {
                var newTileData = modifyTileData(oldTile.Data);
                DebugEx.Assert(newTileData.GetType() == oldTile.Data.GetType());
                FastAddTile(new Tile(tileBaseData, newTileData));
                return true;
            }
            return false;
        }

        public IEnumerable<Tile> GetRegion(Int2 superGridTopLeft)
        {
            if (_superGrid.TryGetValue(superGridTopLeft, out IReadOnlyCollection<Tile> value))
            {
                return value;
            }
            return new Tile[0];
        }

        /// <summary>
        /// Removes a tile that exactly matches the one provided.
        /// </summary>
        public bool Remove(TileBaseData baseData)
        {
            var tile = GetTile(baseData);
            if (tile != null)
            {
                if (tile.Data is IRailTileData railTile && railTile.Trains.Any())
                {
                    var result = RailTiles.Remove(tile);
                    DebugEx.Assert(result, "Couldn't find train tile to remove.");
                }
                return _superGrid.Remove(GridToSuperGrid(baseData.GridPosition), tile);
            }
            return false;
        }
            

        public bool TilesOverlap(Tile tile0, Tile tile1) => 
            RectanglesOverlap(
                tile0.BaseData.GridPosition,
                GetTileSize(tile0), 
                tile1.BaseData.GridPosition,
                GetTileSize(tile1));

        public Int2 GetTileSize(Tile tile)
        {
            var size = TileTypes[tile.BaseData.TileTypeId].GridSize;
            return tile.BaseData.Rotation % 2 == 0
                ? size
                : size.Transpose;
        }

        public Tile GetTile(TileBaseData tileBaseData) =>
            _superGrid.TryGetValue(GridToSuperGrid(tileBaseData.GridPosition), out IReadOnlyCollection<Tile> value)
                ? value.SingleOrDefault(item => item.BaseData == tileBaseData)
                : null;

        public Tile CreateFromName(string tileTypeCodeName, Int2 gridPosition, int rotation)
        {
            var index = TileTypes.FindIndex(item => item.CodeName == tileTypeCodeName);
            return new Tile(new TileBaseData(index, gridPosition, rotation), TileTypes[index].Data.GetDefaultTileData());
        }

        public static bool RectanglesOverlap(Int2 topLeft0, Int2 size0, Int2 topLeft1, Int2 size1)
        {
            DebugEx.Assert(size0.X >= 0 && size0.Y >= 0);
            DebugEx.Assert(size1.X >= 0 && size1.Y >= 0);
            var topRight0 = topLeft0 + new Int2(Math.Max(size0.X - 1, 0), 0);
            var bottomRight0 = topLeft0 + Int2.ComponentMax(new Int2(), size0 - new Int2(1, 1));
            var topRight1 = topLeft1 + new Int2(Math.Max(size1.X - 1, 0), 0);
            var bottomRight1 = topLeft1 + Int2.ComponentMax(new Int2(), size1 - new Int2(1, 1));

            return PointInRectangle(topLeft0, size0, topLeft1)
                || PointInRectangle(topLeft0, size0, topRight1)
                || PointInRectangle(topLeft0, size0, bottomRight1)
                || PointInRectangle(topLeft1, size1, topLeft0)
                || PointInRectangle(topLeft1, size1, topRight0)
                || PointInRectangle(topLeft1, size1, bottomRight0);
        }

        public static bool PointInRectangle(Int2 topLeft, Int2 size, Int2 point)
        {
            DebugEx.Assert(size.X >= 0 && size.Y >= 0);
            var bottomRight = topLeft + size;

            return 
                topLeft.X <= point.X && point.X < bottomRight.X && 
                topLeft.Y <= point.Y && point.Y < bottomRight.Y;
        }
    }
}
