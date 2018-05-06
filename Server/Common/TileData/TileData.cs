using Equ;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common.TileData
{
    public interface ITileData
    {
    }

    public class TileBasic : MemberwiseEquatable<TileBasic>, ITileData
    {
    }

    public class TileRail : MemberwiseEquatable<TileRail>, ITileData
    {
    }

    public class TileRailFork : MemberwiseEquatable<TileRailFork>, ITileData
    {
        public bool IsOn { get; }

        public TileRailFork(bool isOn)
        {
            IsOn = isOn;
        }
    }

    public class TileDepot : MemberwiseEquatable<TileRailFork>, ITileData
    {
        public bool Occupied { get; }

        public TileDepot(bool occupied)
        {
            Occupied = occupied;
        }
    }
}
