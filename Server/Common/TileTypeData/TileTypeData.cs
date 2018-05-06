using Common.TileData;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common.TileTypeData
{
    public interface ITileTypeData
    {
        string GetElmParameter();
        ITileData GetDefaultTileData();
    }

    public static class TileTypeData
    {
        //public static ImmutableDictionary<ITileTypeData, ITileData> TileDataMap =>
        //    new Dictionary<ITileTypeData, ITileData>
        //    {
        //        [typeof(Basic)]
        //    }.ToImmutableDictionary();
    }


    public class Basic : ITileTypeData
    {
        public string GetElmParameter() => "Basic";
        public ITileData GetDefaultTileData() => new TileBasic();
    }

    public class Rail : ITileTypeData
    {
        /// <summary>
        /// A function that defines the path a train will take when moving on this rail tile. 
        /// The path should use the tiles local coordinates and the first rotation sprite for reference.
        /// </summary>
        public ElmFunc<double, Double2> Path { get; }

        public Rail(ElmFunc<double, Double2> path)
        {
            Path = path;
        }

        public string GetElmParameter() => $"(Rail ({Path.ElmCode}))";
        public ITileData GetDefaultTileData() => new TileRail();
    }

    public class RailFork : ITileTypeData
    {
        public ElmFunc<double, Double2> PathOn { get; }
        public ElmFunc<double, Double2> PathOff { get; }

        public RailFork(ElmFunc<double, Double2> pathOn, ElmFunc<double, Double2> pathOff)
        {
            PathOn = pathOn;
            PathOff = pathOff;
        }

        public string GetElmParameter() => $"(RailFork ({PathOn.ElmCode}) ({PathOff.ElmCode}))";
        public ITileData GetDefaultTileData() => new TileRailFork(false);
    }

    public class Depot : ITileTypeData
    {
        public ElmFunc<double, Double2> Path { get; }

        public Depot(ElmFunc<double, Double2> path)
        {
            Path = path;
        }

        public string GetElmParameter() => "Depot";
        public ITileData GetDefaultTileData() => new TileDepot(true);
    }
}
