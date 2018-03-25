using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public class TileType
    {
        public static Int2 MaxGridSize { get; } = new Int2(5, 5);
        public Int2 GridSize { get; }

        public TileType(Int2 gridSize)
        {
            GridSize = gridSize;
        }
    }
}
