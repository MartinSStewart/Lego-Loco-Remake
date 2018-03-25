using System;
using NUnit.Framework;
using Server;

namespace Tests
{
    [TestFixture]
    public class WorldTest
    {
        [TestCase(0, 0, 0, 0, 1, 1, true)]
        [TestCase(-1, -1, 0, 0, 1, 1, true)]
        [TestCase(-1, 0, 0, 0, 1, 1, true)]
        [TestCase(0, -1, 0, 0, 1, 1, true)]
        [TestCase(100, 0, 0, 0, 1, 1, false)]
        [TestCase(-3, -3, 0, 0, 1, 1, false)]
        [TestCase(-3, 0, 0, 0, 1, 1, false)]
        [TestCase(0, -3, 0, 0, 1, 1, false)]
        [TestCase(-2, -2, 0, 0, 1, 1, true)]
        [TestCase(-3, -3, 0, 0, -1, -1, false)]
        [TestCase(0, 0, 3, 0, 3, 3, false)]
        [TestCase(6, 0, 3, 0, 3, 3, false)]
        public void AddAndGetTile(int tileX, int tileY, int regionX, int regionY, int regionWidth, int regionHeight, bool tileInRegion)
        {
            var world = new World();

            world.AddTile(new Tile(0, new Int2(tileX, tileY), 0));

            var result = world.GetRegion(new Int2(regionX, regionY), new Int2(regionWidth, regionHeight));

            var expected = tileInRegion
                ? new[] { new Tile(0, new Int2(tileX, tileY), 0) }
                : new Tile[0];
            Assert.AreEqual(expected, result);
        }
    }
}
