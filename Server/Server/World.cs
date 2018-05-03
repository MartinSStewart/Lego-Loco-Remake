using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MoreLinq;
using Common;

namespace Server
{
    public class World
    {
        public static Int2 MinGridPosition { get; } = new Int2(-1000000, -1000000);
        public static Int2 MaxGridPosition { get; } = new Int2(1000000, 1000000);
        public const int SuperGridSize = 64;

        public int TileCount => _superGrid.Values.SelectMany(item => item).Count();

        public ImmutableList<TileType> TileTypes { get; }

        private readonly MultiValueDictionary<Int2, Tile> _superGrid = new MultiValueDictionary<Int2, Tile>();
        private IEnumerable<Tile> GetTiles(Int2 superGridPosition) =>
            _superGrid.TryGetValue(superGridPosition, out IReadOnlyCollection<Tile> value)
                ? value
                : new Tile[0];

        private Int2 GridToSuperGrid(Int2 gridPosition) =>
            new Int2(
                gridPosition.X / SuperGridSize - (gridPosition.X < 0 ? 1 : 0),
                gridPosition.Y / SuperGridSize - (gridPosition.Y < 0 ? 1 : 0));

        public World(ImmutableList<TileType> tileTypes)
        {
            TileTypes = tileTypes;
        }

        public void AddTile(Tile tile)
        {
            if (!PointInRectangle(MinGridPosition, MaxGridPosition - MinGridPosition, tile.GridPosition))
            {
                return;
            }

            var tileType = TileTypes[tile.TileTypeId];
            var gridPos = tile.GridPosition;
            var superGridPos = GridToSuperGrid(gridPos);

            var superGridTiles = new[]
            {
                new Int2(-1, -1), new Int2(0, -1), new Int2(1, -1),
                new Int2(-1, 0), new Int2(0, 0), new Int2(1, 0),
                new Int2(-1, 1), new Int2(0, 1), new Int2(1, 1),
            }.Select(item => (item + superGridPos, GetTiles(item + superGridPos).ToArray()));

            foreach (var (pos, tiles) in superGridTiles)
            {
                foreach (var otherTile in tiles.Where(item => TilesOverlap(tile, item)))
                {
                    var result = _superGrid.Remove(pos, otherTile);
                    DebugEx.Assert(result, "We should be able to remove the tile from the place we just found it in.");
                }
            }

            _superGrid.Add(superGridPos, tile);
        }

        public void AddTile(string tileTypeName, Int2 gridPosition, int rotation = 0) =>
            AddTile(new Tile(TileTypes.FindIndex(item => item.CodeName == tileTypeName), gridPosition, rotation));

        public IEnumerable<Tile> GetRegion(Int2 superGridTopLeft, Int2 superGridSize) => 
            _superGrid
                .Where(item => PointInRectangle(superGridTopLeft, superGridSize, item.Key))
                .SelectMany(item => item.Value);

        /// <summary>
        /// Removes a tile that exactly matches the one provided.
        /// </summary>
        public bool Remove(Tile tile) => _superGrid.Remove(GridToSuperGrid(tile.GridPosition), tile);

        public bool TilesOverlap(Tile tile0, Tile tile1) => 
            RectanglesOverlap(
                tile0.GridPosition,
                GetTileSize(tile0), 
                tile1.GridPosition,
                GetTileSize(tile1));

        public Int2 GetTileSize(Tile tile)
        {
            var size = TileTypes[tile.TileTypeId].GridSize;
            return tile.Rotation % 2 == 0
                ? size
                : size.Transpose;
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
