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

    public interface IRailTileData : ITileData
    {
        ImmutableList<Train> Trains { get; }
    }

    public class TileBasic : MemberwiseEquatable<TileBasic>, ITileData
    {
    }

    public class TileRail : MemberwiseEquatable<TileRail>, IRailTileData
    {
        public ImmutableList<Train> Trains { get; }

        public TileRail(ImmutableList<Train> trains)
        {
            Trains = trains;
        }
    }

    public class TileRailFork : MemberwiseEquatable<TileRailFork>, IRailTileData
    {
        public ImmutableList<Train> Trains { get; }
        public bool IsOn { get; }

        public TileRailFork(ImmutableList<Train> trains, bool isOn)
        {
            Trains = trains;
            IsOn = isOn;
        }
    }

    public class TileDepot : MemberwiseEquatable<TileDepot>, IRailTileData
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
