using Common.TileTypeData;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public enum TileCategory { Roads, Buildings, Nature }

    public class TileType
    {
        public string CodeName { get; }
        public Int2 GridSize { get; }
        /// <summary>
        /// Sprites used for this <see cref="TileType"/>'s orientations. Array length must be 1, 2, or 4.
        /// </summary>
        public ImmutableList<string> Sprites { get; }
        public string ToolboxIconSprite { get; }
        public TileCategory Category { get; }
        public ITileTypeData Data { get; }


        public TileType(string codeName, Int2 gridSize, string toolboxIconSprite, string[] sprites, TileCategory category, ITileTypeData data)
        {
            DebugEx.Assert(sprites.Length == 1 || sprites.Length == 2 || sprites.Length == 4);
            DebugEx.Assert(sprites.All(Sprite.IsValidElmFunctionName));
            DebugEx.Assert(Sprite.IsValidElmFunctionName(codeName));
            CodeName = codeName;
            GridSize = gridSize;
            Sprites = sprites.ToImmutableList();
            ToolboxIconSprite = toolboxIconSprite;
            Category = category;
            Data = data;
        }

        public void AssertPath(ITileTypeData data)
        {
            var margin = 0.01;
            bool ValueClose(double value0, double value1) => Math.Abs(value0 - value1) < margin;

            bool OnTileEdge(Double2 point) =>
                (ValueClose(point.X, 0) || ValueClose(point.X, GridSize.X)) &&
                (ValueClose(point.Y, 0) || ValueClose(point.Y, GridSize.Y));

            bool OnGridEdge(Double2 point) =>
                (ValueClose(point.X % 1, 0) && ValueClose(point.Y % 1, 0.5)) ||
                (ValueClose(point.Y % 1, 0) && ValueClose(point.X % 1, 0.5));

            bool PathValid(Double2 start, Double2 end) => OnTileEdge(start) && OnGridEdge(start) && OnTileEdge(end) && OnGridEdge(end);

            switch (data)
            {
                case Rail rail:
                    DebugEx.Assert(
                        PathValid(rail.Path.Func(0), rail.Path.Func(1)),
                        "Path must start and end on different grid edges that are also on the edge of the tile.");
                    break;
                case RailFork rail:
                    var pathOnStart = rail.PathOn.Func(0);
                    var pathOffStart = rail.PathOn.Func(0);
                    DebugEx.Assert(
                        PathValid(pathOnStart, rail.PathOn.Func(1)),
                        "On path must start and end on different grid edges that are also on the edge of the tile.");
                    DebugEx.Assert(
                        PathValid(pathOffStart, rail.PathOff.Func(1)),
                        "Off path must start and end on different grid edges that are also on the edge of the tile.");
                    DebugEx.Assert(
                        !ValueClose(pathOnStart.X, pathOffStart.X) || !ValueClose(pathOnStart.Y, pathOffStart.Y),
                        "On and off path must start at the same place.");
                    break;
                case Depot depot:
                    var pathStart = depot.Path.Func(0);
                    DebugEx.Assert(
                        OnGridEdge(pathStart) && OnTileEdge(pathStart) && !OnTileEdge(depot.Path.Func(1)),
                        "Path should start at the edge of the tile and end inside it");
                    break;
                default:
                    throw new NotImplementedException();
            }
        }

        public static ImmutableList<TileType> GetTileTypes()
        {
            var railTurnLeftUp = new ElmFunc<double, Double2>(
                "\\t -> Point2 (sin t) (cos t) |> Point2.rmultScalar 2.5",
                t => new Double2(Math.Sin(t), Math.Cos(t)) * 2.5);

            var railTurnRightUp = new ElmFunc<double, Double2>(
                "\\t -> Point2 -(sin t) (cos t) |> Point2.rmultScalar 2.5 |> Point2.add (Point2 3 0)",
                t => new Double2(-Math.Sin(t) + 3, Math.Cos(t)) * 2.5);

            ElmFunc<double, Double2> RailLinearPath(Double2 start, Double2 end) => new ElmFunc<double, Double2>(
                $"\\t -> Point2 {end.X} {end.Y} |> Point2.rsub (Point2 {start.X} {start.Y}) |> Point2.rmultScalar t |> Point2.add (Point2 {start.X} {start.Y})",
                t => (end - start) * t + start);

            return new[]
            {
                new TileType("sidewalk", new Int2(1, 1), "sidewalk", new[] { "sidewalk" }, TileCategory.Roads, new Basic()),
                new TileType("roadStraight", new Int2(2, 2), "roadHorizontal", new[] { "roadHorizontal", "roadVertical" }, TileCategory.Roads, new Basic()),
                new TileType("roadTurn", new Int2(2, 2), "roadTurnLeftUp", new[] { "roadTurnLeftUp", "roadTurnLeftDown", "roadTurnRightDown", "roadTurnRightUp" }, TileCategory.Roads, new Basic()),

                // Buildings
                new TileType("redHouse", new Int2(3, 3), "redHouseIcon", new[] { "redHouse" }, TileCategory.Buildings, new Basic()),
                
                // Rail
                new TileType(
                    "railStraight",
                    new Int2(1, 1), "railHorizontal",
                    new[] { "railHorizontal", "railVertical" },
                    TileCategory.Roads,
                    new Rail(RailLinearPath(new Double2(0, 0.5), new Double2(1, 0.5)))),
                new TileType(
                    "railTurn",
                    new Int2(3, 3),
                    "railTurnLeftUp",
                    new[] { "railTurnLeftUp", "railTurnLeftDown", "railTurnRightDown", "railTurnRightUp" },
                    TileCategory.Roads,
                    new Rail(railTurnLeftUp)),
                new TileType(
                    "railSplitRight",
                    new Int2(3, 3),
                    "railSplitVerticalLeftUpOff",
                    new[] { "railSplitHorizontalRightUpOff", "railSplitVerticalLeftUpOff", "railSplitHorizontalLeftDownOff", "railSplitVerticalRightDownOff" },
                    TileCategory.Roads,
                    new RailFork(railTurnRightUp, RailLinearPath(new Double2(0, 2.5), new Double2(3, 2.5)))),
                new TileType(
                    "railSplitLeft",
                    new Int2(3, 3),
                    "railSplitHorizontalLeftUpOff",
                    new[] { "railSplitHorizontalLeftUpOff", "railSplitVerticalLeftDownOff", "railSplitHorizontalRightDownOff", "railSplitVerticalRightUpOff" },
                    TileCategory.Roads,
                    new RailFork(railTurnLeftUp, RailLinearPath(new Double2(0, 2.5), new Double2(3, 2.5)))),
                new TileType(
                    "roadRailCrossing",
                    new Int2(3, 2),
                    "roadRailCrossingOpenHorizontal",
                    new[] { "roadRailCrossingOpenHorizontal", "roadRailCrossingOpenVertical" },
                    TileCategory.Roads,
                    new Rail(RailLinearPath(new Double2(1.5, 0), new Double2(1.5, 2)))),
                new TileType(
                    "depot",
                    new Int2(5, 3),
                    "depotLeftOccupied",
                    new[] { "depotLeftOccupied", "depotDownOccupied", "depotRightOccupied", "depotUpOccupied"},
                    TileCategory.Roads,
                    new Depot(RailLinearPath(new Double2(0, 1.5), new Double2(4, 1.5))))
            }.ToImmutableList();
        }

        public static TileType GetDefaultTile() => GetTileTypes().First();
    }
}
