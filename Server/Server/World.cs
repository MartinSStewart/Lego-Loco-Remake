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
            foreach (var collision in _tree.Search(tile.Envelope))
            {
                _tree.Delete(collision);
            }

            _tree.Insert(tile);
        }

        public IReadOnlyList<Tile> GetRegion(Int2 topLeft, Int2 gridSize) => 
            _tree.Search(Tile.GetGridEnvelope(topLeft, gridSize));

        public void Remove(Tile tile)
        {
            _tree.Delete(tile);
        }
    }
}
