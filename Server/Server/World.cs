using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MoreLinq;
using RTree;

namespace Server
{
    public class World
    {
        private RTree<Tile> _tree = new RTree<Tile>();

        public static Int2 MinGridPosition { get; } = new Int2(-1000000, -1000000);
        public static Int2 MaxGridPosition { get; } = new Int2(1000000, 1000000);

        public int TileCount => _tree.Count;

        public ImmutableList<TileType> TileTypes { get; }

        public World(ImmutableList<TileType> tileTypes)
        {
            TileTypes = tileTypes;
        }

        public void AddTile(Tile tile)
        {
            foreach (var collision in _tree.Intersects(GetBounds(tile)))
            {
                _tree.Delete(GetBounds(collision), collision);
            }
            _tree.Add(GetBounds(tile), tile);
        }

        public void AddTile(string tileTypeName, Int2 gridPosition, int rotation = 0) =>
            AddTile(new Tile(TileTypes.FindIndex(item => item.Name == tileTypeName), gridPosition, rotation));

        public IReadOnlyList<Tile> GetRegion(Int2 topLeft, Int2 gridSize) => 
            _tree.Intersects(GetBounds(topLeft, gridSize));

        public bool Remove(Tile tile)
        {
            try
            {
                _tree.Delete(GetBounds(tile), tile);
                return true;
            }
            catch (KeyNotFoundException)
            {
                return false;
            }
        }

        public Rectangle GetBounds(Int2 gridPosition, Int2 gridSize) =>
            // We add some margin to the envelope to rounding errors giving false collisions.
            new Rectangle(
                new[]
                {
                    gridPosition.X + 0.25f,
                    gridPosition.Y + 0.25f,
                    0
                },
                new[]
                {
                    gridPosition.X + gridSize.X - 0.25f,
                    gridPosition.Y + gridSize.Y - 0.25f,
                    0
                });

        public Rectangle GetBounds(Tile tile) => GetBounds(tile.GridPosition, TileTypes[tile.TileTypeId].GridSize);
    }
}
