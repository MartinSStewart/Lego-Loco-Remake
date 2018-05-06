using Common.TileData;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MoreLinq;

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

        public static string SpritesToParams(ImmutableList<string> sprites) => 
            $"(Rot{sprites.Count} {sprites.Select(item => "Sprite." + item).ToDelimitedString(" ")})";
        public static string SpritesToParams(ImmutableList<(string, string)> sprites) => 
            $"(Rot{sprites.Count} {sprites.Select(item => $"( Sprite.{item.Item1}, Sprite.{item.Item2} )").ToDelimitedString(" ")})";
        public static string SpritesToParams(ImmutableList<(string, string, string)> sprites) => 
            $"(Rot{sprites.Count} {sprites.Select(item => $"( Sprite.{item.Item1}, Sprite.{item.Item2}, Sprite.{item.Item3} )").ToDelimitedString(" ")})";
    }


    public class Basic : ITileTypeData
    {
        /// <summary>
        /// Sprites used for this <see cref="TileType"/>'s orientations. Array length must be 1, 2, or 4.
        /// </summary>
        public ImmutableList<string> Sprites { get; }

        public Basic(string[] sprites)
        {
            DebugEx.Assert(sprites.Length == 1 || sprites.Length == 2 || sprites.Length == 4);
            DebugEx.Assert(sprites.All(Sprite.IsValidElmFunctionName));
            Sprites = sprites.ToImmutableList();
        }

        public string GetElmParameter() => $"(Basic {TileTypeData.SpritesToParams(Sprites)})";
        public ITileData GetDefaultTileData() => new TileBasic();
    }

    public class Rail : ITileTypeData
    {
        public ImmutableList<string> Sprites { get; }

        /// <summary>
        /// A function that defines the path a train will take when moving on this rail tile. 
        /// The path should use the tiles local coordinates and the first rotation sprite for reference.
        /// </summary>
        public ElmFunc<double, Double2> Path { get; }

        public Rail(string[] sprites, ElmFunc<double, Double2> path)
        {
            DebugEx.Assert(sprites.Length == 1 || sprites.Length == 2 || sprites.Length == 4);
            DebugEx.Assert(sprites.All(Sprite.IsValidElmFunctionName));
            Sprites = sprites.ToImmutableList();
            Path = path;
        }

        public string GetElmParameter() => $"(Rail\n            {TileTypeData.SpritesToParams(Sprites)}\n            ({Path.ElmCode})\n        )";
        public ITileData GetDefaultTileData() => new TileRail();
    }

    public class RailFork : ITileTypeData
    {
        public ImmutableList<(string PathOn, string PathOff)> Sprites { get; }
        public ElmFunc<double, Double2> PathOn { get; }
        public ElmFunc<double, Double2> PathOff { get; }

        public RailFork((string, string)[] sprites, ElmFunc<double, Double2> pathOn, ElmFunc<double, Double2> pathOff)
        {
            DebugEx.Assert(sprites.Length == 1 || sprites.Length == 2 || sprites.Length == 4);
            DebugEx.Assert(sprites.All(item => Sprite.IsValidElmFunctionName(item.Item1) && Sprite.IsValidElmFunctionName(item.Item2)));
            Sprites = sprites.ToImmutableList();
            PathOn = pathOn;
            PathOff = pathOff;
        }

        public string GetElmParameter() => $"(RailFork\n            {TileTypeData.SpritesToParams(Sprites)}\n            ({PathOn.ElmCode})\n            ({PathOff.ElmCode})\n        )";
        public ITileData GetDefaultTileData() => new TileRailFork(false);
    }

    public class Depot : ITileTypeData
    {
        public ImmutableList<(string Occupied, string Open, string Closed)> Sprites { get; }
        public ElmFunc<double, Double2> Path { get; }

        public Depot((string, string, string)[] sprites, ElmFunc<double, Double2> path)
        {
            DebugEx.Assert(sprites.Length == 1 || sprites.Length == 2 || sprites.Length == 4);
            DebugEx.Assert(sprites.All(item => Sprite.IsValidElmFunctionName(item.Item1) && Sprite.IsValidElmFunctionName(item.Item2) && Sprite.IsValidElmFunctionName(item.Item3)));
            Sprites = sprites.ToImmutableList();
            Path = path;
        }

        public string GetElmParameter() => $"(Depot\n            {TileTypeData.SpritesToParams(Sprites)}\n        )";
        public ITileData GetDefaultTileData() => new TileDepot(true);
    }
}
