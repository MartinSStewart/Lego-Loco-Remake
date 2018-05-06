using Equ;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Common;
using Common.TileData;

namespace Server
{
    public class Tile : MemberwiseEquatable<Tile>
    {
        public TileBaseData BaseData { get; }
        public ITileData Data { get; }

        public Tile(TileBaseData baseData, ITileData data)
        {
            BaseData = baseData;
            Data = data;
        }
    }
}
