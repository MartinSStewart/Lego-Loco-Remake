﻿using System;
using System.Collections.Immutable;
using System.IO;
using Newtonsoft.Json;
using NUnit.Framework;
using Server;

namespace Tests
{
    [TestFixture]
    public class WorldTest
    {
        private static readonly ImmutableList<TileType> _tileTypes = TileType.GetTileTypes();

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
            
            var world = new World(_tileTypes);

            world.AddTile("Red House", new Int2(tileX, tileY), 0);

            var result = world.GetRegion(new Int2(regionX, regionY), new Int2(regionWidth, regionHeight));

            var expected = tileInRegion
                ? new[] { new Tile(world.TileTypes.FindIndex(item => item.Name == "Red House"), new Int2(tileX, tileY), 0) }
                : new Tile[0];
            Assert.AreEqual(expected, result);
        }

        [Test]
        public void BugTest()
        {
            var world = new World(_tileTypes);

            var random = new Random(123123);
            for (var i = 0; i < 1000; i++)
            {
                world.AddTile(RandomTile(random, new Int2(-100, -100), new Int2(100, 100)));
            }

            world.AddTile("Red House", new Int2(120, 20), 0);

            var result = world.GetRegion(new Int2(118, 19), new Int2(5, 5));
            Assert.AreEqual(1, result.Count);
        }

        [Test]
        public void RemoveTest()
        {
            var world = new World(_tileTypes);

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
                world.Remove(tile);
            }

            Assert.AreEqual(0, world.TileCount);
        }

        public static Tile RandomTile(Random random, Int2 min, Int2 max)
        {
            return new Tile(
                random.Next(_tileTypes.Count),
                new Int2(random.Next(min.X, max.X), random.Next(min.Y, max.Y)), 
                random.Next(3));
        }

        [Test]
        public void SidewalkTileCollisionBug()
        {
            var world = new World(_tileTypes);
            world.AddTile("Sidewalk", new Int2());
            world.AddTile("Red House", new Int2(1, 0));

            Assert.AreEqual(2, world.TileCount);
        }
    }
}
