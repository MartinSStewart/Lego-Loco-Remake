using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MoreLinq;
using RBush;

namespace Server
{
    public class World
    {
        private RBush<Tile> _tree = new RBush<Tile>();

        public static ImmutableArray<TileType> TileTypes { get; } = 
            new[] 
            {
                new TileType(new Int2(3, 3)),
                new TileType(new Int2(1, 1)),
                new TileType(new Int2(2, 2)),
                new TileType(new Int2(2, 2))
            }.ToImmutableArray();

        public void AddTile(Tile tile)
        {
            //var tileType = GetTileType(tile);
            //var gridPos = tile.GridPosition;

            //// Remove all the tiles to the bottom right of new tile.
            //for (int x = gridPos.X; x < gridPos.X + tileType.GridSize.X; x++)
            //{
            //    for (int y = gridPos.Y; y < gridPos.Y + tileType.GridSize.Y; y++)
            //    {
            //        Tiles.Remove(new Int2(x, y));
            //    }
            //}

            //// Remove all the tiles above or left of the new tile.
            //for (int x = gridPos.X - TileType.MaxGridSize.X + 1; x < gridPos.X; x++)
            //{
            //    for (int y = gridPos.Y - TileType.MaxGridSize.Y + 1; y < gridPos.Y; y++)
            //    {
            //        if (x >= gridPos.X && y >= gridPos.Y)
            //        {
            //            continue;
            //        }
            //        var xy = new Int2(x, y);
            //        Tiles.TryGetValue(xy, out Tile otherTile);

            //        if (RectanglesOverlap(gridPos, tileType.GridSize, otherTile.GridPosition, GetTileType(otherTile).GridSize))
            //        {
            //            Tiles.Remove(xy);
            //        }
            //    }
            //}

            //Tiles[tile.GridPosition] = tile;
            foreach (var collision in _tree.Search(tile.Envelope))
            {
                _tree.Delete(collision);
            }

            _tree.Insert(tile);
        }

        public IReadOnlyList<Tile> GetTiles(Int2 topLeft, Int2 gridSize) => 
            _tree.Search(Tile.GetGridEnvelope(topLeft, gridSize));

        //public bool RectanglesOverlap(Int2 topLeft0, Int2 size0, Int2 topLeft1, Int2 size1)
        //{
        //    var topRight0 = topLeft0 + new Int2(size1.Y - 1, 0);

        //    var bottomRight0 = topLeft0 + size0 - new Int2(1, 1);

        //    var topRight1 = topLeft1 + new Int2(size1.X - 1, 0);

        //    var bottomRight1 = topLeft1 + size1 - new Int2(1, 1);

        //    return PointInRectangle(topLeft0, size0, topLeft1)
        //        || PointInRectangle(topLeft0, size0, topRight1)
        //        || PointInRectangle(topLeft0, size0, bottomRight1)
        //        || PointInRectangle(topLeft1, size1, topLeft0)
        //        || PointInRectangle(topLeft1, size1, topRight0)
        //        || PointInRectangle(topLeft1, size1, bottomRight0);
        //}

        //public bool PointInRectangle(Int2 topLeft, Int2 size, Int2 point)
        //{
        //    var bottomRight = topLeft + size;
        //    return topLeft.X <= point.X && point.X < bottomRight.X && topLeft.Y <= point.Y && point.Y < bottomRight.Y;
        //}

        public void Remove(Tile tile)
        {
            _tree.Delete(tile);
            //Tiles.Remove(tile.GridPosition);
        }
    }
}
