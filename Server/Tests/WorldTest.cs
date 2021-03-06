﻿using System;
using System.Collections.Immutable;
using System.IO;
using System.Linq;
using Common;
using Newtonsoft.Json;
using NUnit.Framework;
using Server;

namespace Tests
{
    [TestFixture]
    public class WorldTest
    {
        private static readonly ImmutableList<TileType> _tileTypes = TileType.GetTileTypes();

        [TestCase(0, 0, 0, 0, true)]
        [TestCase(-1, -1, 0, 0, false)]
        [TestCase(-1, 0, 0, 0, false)]
        [TestCase(0, -1, 0, 0, false)]
        [TestCase(100, 0, 0, 0, false)]
        [TestCase(-3, -3, 0, 0, false)]
        [TestCase(-3, 0, 0, 0, false)]
        [TestCase(0, -3, 0, 0, false)]
        [TestCase(-2, -2, 0, 0, false)]
        [TestCase(0, 0, 3, 0, false)]
        [TestCase(6, 0, 3, 0, false)]
        public void AddAndGetTile(int tileX, int tileY, int superGridX, int superGridY, bool tileInRegion)
        {
            var world = new World(_tileTypes, new DateTime());

            world.AddTile("redHouse", new Int2(tileX, tileY), 0);

            var result = world.GetRegion(new Int2(superGridX, superGridY));

            var expected = tileInRegion
                ? new[] { world.CreateFromName("redHouse", new Int2(tileX, tileY), 0) }
                : new Tile[0];
            Assert.AreEqual(expected, result);
        }

        [Test]
        public void RectanglesOverlapBugTest()
        {
            Assert.IsFalse(World.RectanglesOverlap(new Int2(20, 51), new Int2(1, 1), new Int2(21, 50), new Int2(3, 3)));
        }

        [Test]
        public void RectanglesOverlapSizeZeroInvariant()
        {
            var r = new Random(223123);
            for (var i = 0; i < 500; i++)
            {
                var topLeft = RandomInt2(r, new Int2(-10, -10), new Int2(10, 10));
                var size = RandomInt2(r, new Int2(0, 0), new Int2(10, 10));
                var point = RandomInt2(r, new Int2(-10, -10), new Int2(10, 10));
                var result = World.RectanglesOverlap(topLeft, size, point, new Int2());
                var expected = World.PointInRectangle(topLeft, size, point);
                Assert.AreEqual(expected, result);
            }
        }

        [Test]
        public void RectangleOverlapSize1()
        {
            for (var x = -1; x < 4; x++)
            {
                for (var y = -1; y < 4; y++)
                {
                    var result = World.RectanglesOverlap(new Int2(), new Int2(3, 3), new Int2(x, y), new Int2(1, 1));
                    var expected = !(x < 0 || x > 2 || y < 0 || y > 2);
                    Assert.AreEqual(expected, result);
                }
            }
        }

        [Test]
        public void RectangleOverlapSize2()
        {
            for (var x = -2; x < 4; x++)
            {
                for (var y = -2; y < 4; y++)
                {
                    var result = World.RectanglesOverlap(new Int2(), new Int2(3, 3), new Int2(x, y), new Int2(2, 2));
                    var expected = !(x < -1 || x > 2 || y < -1 || y > 2);
                    Assert.AreEqual(expected, result);
                }
            }
        }

        [Test]
        public void RemoveTest()
        {
            var world = new World(_tileTypes, new DateTime());

            var seed = 123123;
            var random0 = new Random(seed);
            
            for (int i = 0; i < 10000; i++)
            {
                var tile = RandomTile(random0, World.MinGridPosition, World.MaxGridPosition);
                world.AddTile(tile);
            }

            var random1 = new Random(seed);
            for (int i = 0; i < 10000; i++)
            {
                var tile = RandomTile(random1, World.MinGridPosition, World.MaxGridPosition);
                world.Remove(tile.BaseData);
            }

            Assert.AreEqual(0, world.TileCount);
        }

        public static Tile RandomTile(Random random, Int2 min, Int2 max)
        {
            var index = random.Next(_tileTypes.Count);
            return new Tile(
                new TileBaseData(
                    index,
                    new Int2(random.Next(min.X, max.X), random.Next(min.Y, max.Y)), 
                    random.Next(3)),
                _tileTypes[index].Data.GetDefaultTileData());
        }

        public static Int2 RandomInt2(Random random, Int2 min, Int2 max) =>
            new Int2(random.Next(min.X, max.X), random.Next(min.Y, max.Y));

        [Test]
        public void SidewalkTileCollisionBug()
        {
            var world = new World(_tileTypes, new DateTime());
            world.AddTile("sidewalk", new Int2());
            world.AddTile("redHouse", new Int2(1, 0));

            Assert.AreEqual(2, world.TileCount);
        }

        [TestCase(World.SuperGridSize - 1, World.SuperGridSize, 0, 1)]
        [TestCase(World.SuperGridSize, World.SuperGridSize - 1, 1, 0)]
        [TestCase(0, 0, 0, 0)]
        [TestCase(-1, -1, -1, -1)]
        [TestCase(-World.SuperGridSize, -World.SuperGridSize + 1, -2, -1)]
        [TestCase(-World.SuperGridSize + 1, -World.SuperGridSize, -1, -2)]
        public void GridToSuperGridTest(int gridX, int gridY, int expectedSuperGridX, int expectedSuperGridY)
        {
            var result = World.GridToSuperGrid(new Int2(gridX, gridY));
            var expected = new Int2(expectedSuperGridX, expectedSuperGridY);
            Assert.AreEqual(expected, result);
        }
    }
}
