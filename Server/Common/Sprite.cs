using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public class Sprite
    {
        public string CodeName { get; }
        public string ImagePath { get; }
        public Int2 Origin { get; }

        public Sprite(string imagePath, Int2 origin = new Int2(), string codeName = null)
        {
            CodeName = codeName ?? Path.GetFileNameWithoutExtension(imagePath);
            DebugEx.Assert(IsValidElmFunctionName(CodeName));
            Origin = origin;
            ImagePath = imagePath;
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

                // Road
                new Sprite("roadHorizontal.png"),
                new Sprite("roadVertical.png"),
                new Sprite("roadTurnLeftUp.png"),
                new Sprite("roadTurnLeftDown.png"),
                new Sprite("roadTurnRightUp.png"),
                new Sprite("roadTurnRightDown.png"),
                new Sprite("roadRailCrossingOpenHorizontal.png"),
                new Sprite("roadRailCrossingClosedHorizontal.png"),
                new Sprite("roadRailCrossingOpenVertical.png"),
                new Sprite("roadRailCrossingClosedVertical.png"),

                // Toybox
                new Sprite("toyboxRight.png"),
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
                new Sprite("toyboxHouse.png"),

                // Rail
                new Sprite("railHorizontal.png"),
                new Sprite("railVertical.png"),
                new Sprite("railTurnLeftUp.png"),
                new Sprite("railTurnLeftDown.png"),
                new Sprite("railTurnRightUp.png"),
                new Sprite("railTurnRightDown.png"),
                new Sprite("railSplitHorizontalRightUpOn.png"),
                new Sprite("railSplitHorizontalRightUpOff.png"),
                new Sprite("railSplitHorizontalRightDownOn.png"),
                new Sprite("railSplitHorizontalRightDownOff.png"),
                new Sprite("railSplitHorizontalLeftUpOn.png"),
                new Sprite("railSplitHorizontalLeftUpOff.png"),
                new Sprite("railSplitHorizontalLeftDownOn.png"),
                new Sprite("railSplitHorizontalLeftDownOff.png"),
                new Sprite("railSplitVerticalRightUpOn.png"),
                new Sprite("railSplitVerticalRightUpOff.png"),
                new Sprite("railSplitVerticalRightDownOn.png"),
                new Sprite("railSplitVerticalRightDownOff.png"),
                new Sprite("railSplitVerticalLeftUpOn.png"),
                new Sprite("railSplitVerticalLeftUpOff.png"),
                new Sprite("railSplitVerticalLeftDownOn.png"),
                new Sprite("railSplitVerticalLeftDownOff.png"),
                new Sprite("depotUpOpen.png"),
                new Sprite("depotUpOccupied.png"),
                new Sprite("depotUpClosed.png"),
                new Sprite("depotDownOpen.png", new Int2(0, 10)),
                new Sprite("depotDownOccupied.png", new Int2(0, 10)),
                new Sprite("depotDownClosed.png", new Int2(0, 10)),
                new Sprite("depotLeftOpen.png", new Int2(0, 10)),
                new Sprite("depotLeftOccupied.png", new Int2(0, 9)),
                new Sprite("depotLeftClosed.png", new Int2(0, 9)),
                new Sprite("depotRightOpen.png", new Int2(0, 10)),
                new Sprite("depotRightOccupied.png", new Int2(0, 9)),
                new Sprite("depotRightClosed.png", new Int2(0, 9)),
            }.ToImmutableList();
    }
}
