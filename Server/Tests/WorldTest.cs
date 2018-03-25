using System;
using NUnit.Framework;
using Server;

namespace Tests
{
    [TestFixture]
    public class WorldTest
    {
        [Test]
        public void AddAndGetTile()
        {
            var world = new World();

            world.AddTile(new Tile(0, new Int2(), 0));

            var result = world.GetTiles(new Int2(), new Int2(1, 1));
            var expected = new[] { new Tile(0, new Int2(), 0) };
            Assert.AreEqual(expected, result);
        }
    }
}
