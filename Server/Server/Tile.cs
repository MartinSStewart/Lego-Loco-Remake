using Equ;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public class Tile : MemberwiseEquatable<Tile>
    {
        public int TileTypeId { get; }
        public Int2 GridPosition { get; }
        /// <summary>
        /// Number of clockwise 90 degree turns applied to this tile.
        /// </summary>
        public int Rotation { get; }

        public Tile(int tileTypeId, Int2 gridPosition, int rotation)
        {
            DebugEx.Assert(tileTypeId >= 0, "Tile ids must be non-negative.");
            DebugEx.Assert(rotation >= 0 && rotation < 4);
            TileTypeId = tileTypeId;
            GridPosition = gridPosition;
            Rotation = rotation;
        }
    }
}
