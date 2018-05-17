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
            DebugEx.Assert(baseData != null);
            DebugEx.Assert(data != null);
            BaseData = baseData;
            Data = data;
        }

        public Tile With(TileBaseData baseData = null, ITileData data = null) =>
            new Tile(baseData ?? BaseData, data ?? Data);
    }
}
