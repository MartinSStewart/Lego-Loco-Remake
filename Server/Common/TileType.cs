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


        public TileType(string codeName, Int2 gridSize, string toolboxIconSprite, string[] sprites, TileCategory category)
        {
            DebugEx.Assert(sprites.Length == 1 || sprites.Length == 2 || sprites.Length == 4);
            DebugEx.Assert(sprites.All(Sprite.IsValidElmFunctionName));
            DebugEx.Assert(Sprite.IsValidElmFunctionName(codeName));
            CodeName = codeName;
            GridSize = gridSize;
            Sprites = sprites.ToImmutableList();
            ToolboxIconSprite = toolboxIconSprite;
            Category = category;
        }

        public static ImmutableList<TileType> GetTileTypes() =>
            new[] 
            {
                new TileType("sidewalk", new Int2(1, 1), "sidewalk", new[] { "sidewalk" }, TileCategory.Roads),
                new TileType("roadStraight", new Int2(2, 2), "roadHorizontal", new[] { "roadHorizontal", "roadVertical" }, TileCategory.Roads),
                new TileType("roadTurn", new Int2(2, 2), "roadTurnLeftUp", new[] { "roadTurnLeftUp", "roadTurnLeftDown", "roadTurnRightDown", "roadTurnRightUp" }, TileCategory.Roads),
                new TileType("redHouse", new Int2(3, 3), "redHouseIcon", new[] { "redHouse" }, TileCategory.Buildings),
                new TileType("roadRailCrossing", new Int2(3, 2), "roadRailCrossingOpenHorizontal", new[] { "roadRailCrossingOpenHorizontal", "roadRailCrossingOpenVertical" }, TileCategory.Roads),

                // Rail
                new TileType("railStraight", new Int2(1, 1), "railHorizontal", new[] { "railHorizontal", "railVertical" }, TileCategory.Roads),
                new TileType("railTurn", new Int2(2, 2), "railTurnLeftUp", new[] { "railTurnLeftUp", "railTurnLeftDown", "railTurnRightDown", "railTurnRightUp" }, TileCategory.Roads),
                new TileType("railSplitRight", new Int2(2, 2), "railSplitVerticalLeftUpOff", new[] { "railSplitVerticalLeftUpOff", "railSplitHorizontalLeftDownOff", "railSplitVerticalRightDownOff", "railSplitHorizontalRightUpOff" }, TileCategory.Roads),
                new TileType("railSplitLeft", new Int2(2, 2), "railSplitHorizontalLeftUpOff", new[] { "railSplitHorizontalLeftUpOff", "railSplitVerticalLeftDownOff", "railSplitHorizontalRightDownOff", "railSplitVerticalRightUpOff" }, TileCategory.Roads),
            }.ToImmutableList();

        public static TileType GetDefaultTile() => GetTileTypes().First();
    }
}
