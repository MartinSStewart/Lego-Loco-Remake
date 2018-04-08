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
            foreach (var collision in _tree.Intersects(tile.Bounds))
            {
                _tree.Delete(collision.Bounds, collision);
            }
            
            _tree.Add(tile.Bounds, tile);
        }

        public IReadOnlyList<Tile> GetRegion(Int2 topLeft, Int2 gridSize) => 
            _tree.Intersects(Tile.GetBounds(topLeft, gridSize));

        public bool Remove(Tile tile)
        {
            try
            {
                _tree.Delete(tile.Bounds, tile);
                return true;
            }
            catch (KeyNotFoundException)
            {
                return false;
            }
        }
    }
}
