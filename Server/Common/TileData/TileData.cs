using Equ;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
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
        public ImmutableList<Train> Trains { get; }

        public TileRail(ImmutableList<Train> trains)
        {
            Trains = trains;
        }
    }

    public class TileRailFork : MemberwiseEquatable<TileRailFork>, ITileData
    {
        public ImmutableList<Train> Trains { get; }
        public bool IsOn { get; }

        public TileRailFork(ImmutableList<Train> trains, bool isOn)
        {
            Trains = trains;
            IsOn = isOn;
        }
    }

    public class TileDepot : MemberwiseEquatable<TileDepot>, ITileData
    {
        public ImmutableList<Train> Trains { get; }
        public bool Occupied { get; }

        public TileDepot(ImmutableList<Train> trains, bool occupied)
        {
            Trains = trains;
            Occupied = occupied;
        }
    }
}
