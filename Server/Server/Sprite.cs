using Newtonsoft.Json;
using Server;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.IO;
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
        /// <summary>
        /// If null, the pixel dimensions of the image are used.
        /// </summary>
        public Int2? Size { get; }

        public Sprite(string imagePath, Int2 origin = new Int2(), string codeName = null, Int2? size = null)
        {
            CodeName = codeName ?? Path.GetFileNameWithoutExtension(imagePath);
            DebugEx.Assert(IsValidElmFunctionName(CodeName));
            Origin = origin;
            ImagePath = imagePath;
            Size = size;
        }

        public static bool IsValidElmFunctionName(string name) =>
            char.IsLower(name[0]) &&
            name.All(item => char.IsLetterOrDigit(item));

        public static ImmutableList<Sprite> GetSprites() =>
            new[]
            {
                new Sprite("sidewalk.png"),
                new Sprite("grid.png"),
                new Sprite("redHouse.png", new Int2(0, 10)),
                new Sprite("redHouseIcon.png"),
                new Sprite("roadHorizontal.png"),
                new Sprite("roadVertical.png"),
                new Sprite("roadTurnLeftUp.png"),
                new Sprite("roadTurnLeftDown.png"),
                new Sprite("roadTurnRightUp.png"),
                new Sprite("roadTurnRightDown.png"),
                new Sprite("toybox.png"),
                new Sprite("toyboxHandle.png", new Int2(0, 18)),
                new Sprite("toyboxTileButtonDown.png"),
                new Sprite("toyboxMenuButtonDown.png"),
                new Sprite("toyboxMenuButtonUp.png"),
                new Sprite("toyboxLeft.png"),
                new Sprite("toyboxPlants.png"),
                new Sprite("toyboxBomb.png"),
                new Sprite("toyboxEraser.png"),
                new Sprite("toyboxLeftArrow.png"),
                new Sprite("toyboxRailroad.png"),
                new Sprite("toyboxHouse.png")
            }.ToImmutableList();
    }
}
