using Equ;
using RTree;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public class Tile : MemberwiseEquatable<Tile>
    {
        public uint TileTypeId { get; }
        public Int2 GridPosition { get; }
        /// <summary>
        /// Number of clockwise 90 degree turns applied to this tile.
        /// </summary>
        public int Rotation { get; }

        [Newtonsoft.Json.JsonIgnore]
        public TileType TileType => World.TileTypes[(int)TileTypeId];

        [Newtonsoft.Json.JsonIgnore]
        public Rectangle Bounds => GetBounds(GridPosition, TileType.GridSize);

        public Tile(uint tileTypeId, Int2 gridPosition, int rotation)
        {
            TileTypeId = tileTypeId;
            GridPosition = gridPosition;
            Rotation = rotation;
        }

        public static Rectangle GetBounds(Int2 gridPosition, Int2 gridSize) =>
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
    }
}
