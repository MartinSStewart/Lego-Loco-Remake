using Newtonsoft.Json;
using Server;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public class Sprite
    {
        public string CodeName { get; }
        public string ImagePath { get; }
        public Int2 Origin { get; }

        public Sprite(string codeName, Int2 origin, string imagePaths)
        {
            DebugEx.Assert(IsValidElmFunctionName(codeName));
            CodeName = codeName;
            Origin = origin;
            ImagePath = imagePaths;
        }

        public static bool IsValidElmFunctionName(string name) =>
            char.IsLower(name[0]) &&
            name.All(item => char.IsLetterOrDigit(item));

        public static ImmutableList<Sprite> GetSprites() =>
            new[]
            {
                new Sprite("sidewalk", new Int2(0, 0),"sidewalk.png"),
                new Sprite("grid", new Int2(0, 0),"grid.png"),
                new Sprite("redHouse", new Int2(0, 10),"redHouse.png"),
                new Sprite("redHouseIcon", new Int2(0, 0),"redHouseIcon.png"),
                new Sprite("roadHorizontal", new Int2(0, 0),"roadHorizontal.png" ),
                new Sprite("roadVertical", new Int2(0, 0),"roadVertical.png" ),
                new Sprite("roadTurnLeftUp", new Int2(0, 0),"roadTurnLeftUp.png"),
                new Sprite("roadTurnLeftDown", new Int2(0, 0), "roadTurnLeftDown.png"),
                new Sprite("roadTurnRightUp", new Int2(0, 0),"roadTurnRightUp.png"),
                new Sprite("roadTurnRightDown", new Int2(0, 0),"roadTurnRightDown.png"),
                new Sprite("toolbox", new Int2(0, 0),"toolbox.png"),
                new Sprite("toolboxHandle", new Int2(0, 18), "toolboxHandle.png"),
                new Sprite("toolboxTileButtonDown", new Int2(0, 0),"toolboxTileButtonDown.png")
            }.ToImmutableList();
    }
}
