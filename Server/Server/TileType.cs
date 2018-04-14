using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public class TileType
    {
        public string CodeName { get; }
        public string Name { get; }
        public Int2 GridSize { get; }
        /// <summary>
        /// Sprites used for this <see cref="TileType"/>'s orientations. Array length must be 1, 2, or 4.
        /// </summary>
        public ImmutableList<string> Sprites { get; }
        public string ToolboxIconSprite { get; }


        public TileType(string codeName, string toolboxName, Int2 gridSize, string toolboxIconSprite, string[] sprites)
        {
            DebugEx.Assert(sprites.Length == 1 || sprites.Length == 2 || sprites.Length == 4);
            DebugEx.Assert(sprites.All(Sprite.IsValidElmFunctionName));
            DebugEx.Assert(Sprite.IsValidElmFunctionName(codeName));
            CodeName = codeName;
            Name = toolboxName;
            GridSize = gridSize;
            Sprites = sprites.ToImmutableList();
            ToolboxIconSprite = toolboxIconSprite;
        }

        public static ImmutableList<TileType> GetTileTypes() =>
            new[] 
            {
                new TileType("sidewalk", "Sidewalk", new Int2(1, 1), "sidewalk", new[] { "sidewalk" }),
                new TileType("straightRoad", "Straight Road", new Int2(2, 2), "roadHorizontal", new[] { "roadHorizontal", "roadVertical" }),
                new TileType("roadTurn", "Road Turn", new Int2(2, 2), "roadTurnLeftUp", new[] { "roadTurnLeftUp", "roadTurnLeftDown", "roadTurnRightDown", "roadTurnRightUp" }),
                new TileType("redHouse", "Red House", new Int2(3, 3), "redHouseIcon", new[] { "redHouse" })
            }.ToImmutableList();

        public static TileType GetDefaultTile() => GetTileTypes().First();
    }
}
