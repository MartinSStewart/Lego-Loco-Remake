using Common;
using Common.TileData;
using NUnit.Framework;
using Server;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Tests
{
    [TestFixture]
    public class TrainTest
    {
        [TestCase(0, 0, 1.5)]
        [TestCase(1, 1.5, 5)]
        [TestCase(2, 5, 1.5)]
        [TestCase(3, 1.5, 0)]
        public void PathRotatesCorrectly(int rotation, double expectedX, double expectedY)
        {
            var random = new Random(123123);
            for (var i = 0; i < 100; i++)
            {
                var gridX = random.Next(World.MinGridPosition.X, World.MaxGridPosition.X);
                var gridY = random.Next(World.MinGridPosition.Y, World.MaxGridPosition.Y);

                var world = new World(TileType.GetTileTypes(), new DateTime());

                var tile = world.CreateFromName("depot", new Int2(gridX, gridY), rotation);
                var size = world.GetTileSize(tile);
                var path = world.GetGridPath(tile);

                Assert.AreEqual(gridX + expectedX, path(0).X, 0.01);
                Assert.AreEqual(gridY + expectedY, path(0).Y, 0.01);
            }
        }

        [Test]
        public void MoveOnPathFuzzTest()
        {
            var random = new Random(123123);
            for (var i = 0; i < 10000; i++)
            {
                var startT = random.NextDouble();
                var startMovement = (random.NextDouble() - 0.5) * 50;

                MoveOnPath(startT, startMovement);
            }
        }

        [TestCase(0, 0)]
        [TestCase(0.5, 0)]
        [TestCase(1, 0)]
        [TestCase(1, 1)]
        [TestCase(0, 1)]
        [TestCase(0, 0.5)]
        [TestCase(0.739, -0.676)]
        [TestCase(0.7175, -0.73047)]
        [TestCase(0.43697706444048184, 0.5185396529354791)]
        public void MoveOnPath(double startT, double startMovement)
        {
            var result = TrainHelper.MoveOnPath(t => new Double2(t, 0), startT, startMovement);

            Assert.AreEqual((startMovement + startT).Clamp(0, 1), result.T, 0.0001);
            if (startMovement > 0)
            {
                Assert.AreEqual(Math.Max(0, startMovement - (1 - startT)), result.MovementLeft, 0.0001);
            }
            else
            {
                Assert.AreEqual(Math.Min(0, startMovement + startT), result.MovementLeft, 0.0001);
            }
        }

        [TestCase(0.0)]
        [TestCase(0.5)]
        [TestCase(0.999999999999)]
        [TestCase(1.0)]
        [TestCase(1.000000000001)]
        [TestCase(1.4)]
        [TestCase(2)]
        [TestCase(2.6)]
        [TestCase(6)]
        public void MoveTrainHorizontally(double trainSpeed)
        {
            var random = new Random(123123);
            for (var i = 0; i < 100; i++)
            {
                var world = new World(TileType.GetTileTypes(), new DateTime());

                var train = new Train(0, trainSpeed, true, 0);

                var gridX = random.Next(World.MinGridPosition.X, World.MaxGridPosition.X);
                var gridY = random.Next(World.MinGridPosition.Y, World.MaxGridPosition.Y);

                var trackLength = 5;
                for (var j = 0; j < trackLength; j++)
                {
                    var tile = world.CreateFromName("railStraight", new Int2(j + gridX, gridY), 0);
                    if (j == 0)
                    {
                        tile = tile.With(data: new TileRail(new[] { train }.ToImmutableList()));
                    }
                    world.AddTile(tile);
                }

                var startPos = world.GetTrainPosition(train.Id) ?? new Double2();

                world.MoveTrains(new DateTime() + TimeSpan.FromSeconds(1));

                var endPos = world.GetTrainPosition(train.Id) ?? new Double2();

                Assert.AreEqual(startPos.X + Math.Min(trainSpeed, trackLength), endPos.X, 0.0001);
                Assert.AreEqual(gridY + 0.5, endPos.Y, 0.0001);
            }
        }

        [TestCase(0.0)]
        [TestCase(0.5)]
        [TestCase(0.999999999999)]
        [TestCase(1.0)]
        [TestCase(1.000000000001)]
        [TestCase(1.4)]
        [TestCase(2)]
        [TestCase(2.6)]
        [TestCase(6)]
        public void MoveTrainVertically(double trainSpeed)
        {
            var random = new Random(123123);
            for (var i = 0; i < 100; i++)
            {
                var world = new World(TileType.GetTileTypes(), new DateTime());

                var train = new Train(1, trainSpeed, false, 0);

                var gridX = random.Next(World.MinGridPosition.X, World.MaxGridPosition.X);
                var gridY = random.Next(World.MinGridPosition.Y, World.MaxGridPosition.Y);

                var trackLength = 5;
                for (var j = 0; j < trackLength; j++)
                {
                    var tile = world.CreateFromName("railStraight", new Int2(gridX, j + gridY), 1);
                    if (j == 0)
                    {
                        tile = tile.With(data: new TileRail(new[] { train }.ToImmutableList()));
                    }
                    world.AddTile(tile);
                }

                var startPos = world.GetTrainPosition(train.Id) ?? new Double2();

                world.MoveTrains(new DateTime() + TimeSpan.FromSeconds(1));

                var endPos = world.GetTrainPosition(train.Id) ?? new Double2();

                Assert.AreEqual(startPos.Y + Math.Min(trainSpeed, trackLength), endPos.Y, 0.0001);
                Assert.AreEqual(gridX + 0.5, endPos.X, 0.0001);
            }
        }

        [Test]
        public void ClickingOnDepotSendsOutTrain()
        {
            var world = new World(TileType.GetTileTypes(), new DateTime());

            var depot = world.CreateFromName("depot", new Int2(), 2);
            world.AddTile(depot);
            world.AddTile(world.CreateFromName("railStraight", new Int2(6, 1), 0));

            Assert.IsTrue(world.ClickTile(depot.BaseData));
            var expected = new[]
            {
                depot.With(data: new TileDepot(new[] { new Train(1, World.TrainSpeed, false, 0) }.ToImmutableList(), false))
            };
            Assert.AreEqual(expected, world.RailTiles);
        }

        [Test]
        public void TrainLeavesDepot()
        {
            var world = new World(TileType.GetTileTypes(), new DateTime());

            var depot = world.CreateFromName("depot", new Int2(), 2);
            world.AddTile(depot);
            var rail = world.CreateFromName("railStraight", new Int2(5, 1), 0);
            world.AddTile(rail);

            world.ClickTile(depot.BaseData);

            world.MoveTrains(new DateTime() + TimeSpan.FromSeconds(3));

            var expected = new[]
            {
                rail.With(data: new TileRail(new[] { new Train(1, World.TrainSpeed, true, 0) }.ToImmutableList()))
            };
            Assert.AreEqual(expected, world.RailTiles);
        }

        [TestCase(true)]
        [TestCase(false)]
        public void TrainTurn(bool turnUp)
        {
            var world = new World(TileType.GetTileTypes(), new DateTime());

            var depot = world.CreateFromName("depot", new Int2(), 2);
            world.AddTile(depot);
            var rail = world.CreateFromName("railTurn", new Int2(5, turnUp ? -1 : 1), turnUp ? 0 : 1);
            world.AddTile(rail);

            world.ClickTile(depot.BaseData);

            world.MoveTrains(new DateTime() + TimeSpan.FromSeconds(3));

            var expected = new[]
            {
                rail.With(data: new TileRail(new[] { new Train(turnUp ? 1 : 0, World.TrainSpeed, turnUp, 0) }.ToImmutableList()))
            };
            Assert.AreEqual(expected, world.RailTiles);
        }

        [Test]
        public void TrainFlipsTurnFork()
        {
            var world = new World(TileType.GetTileTypes(), new DateTime());

            var depot = world.CreateFromName("depot", new Int2(), 2);
            world.AddTile(depot);
            var rail = world.CreateFromName("railSplitLeft", new Int2(5, 1), 1);
            world.AddTile(rail);

            world.ClickTile(depot.BaseData);

            world.MoveTrains(new DateTime() + TimeSpan.FromSeconds(3));

            var expected = new[]
            {
                rail.With(data: new TileRailFork(new[] { new Train(0, World.TrainSpeed, false, 0) }.ToImmutableList(), true))
            };
            Assert.AreEqual(expected, world.RailTiles);
        }

        [Test]
        public void StackOverflowTest()
        {
            var world = new World(TileType.GetTileTypes(), new DateTime());

            world.AddTile(
                new Tile(
                    new TileBaseData(world.TileTypes.FindIndex(item => item.CodeName == "railTurn"), new Int2(40, 25), 3),
                    new TileRail(new[] { new Train(0.99785386021710187, 4, true, 3) }.ToImmutableList())));

            world.AddTile("railSplitRight", new Int2(43, 22), 1);

            world.AddTile(new Tile(new TileBaseData(6, new Int2(43, 25), 1), new TileRailFork(ImmutableList<Train>.Empty, true)));

            world.MoveTrains(new DateTime() + TimeSpan.FromMilliseconds(100));
        }

        [Test]
        public void StackOverflowTest2()
        {
            var world = new World(TileType.GetTileTypes(), new DateTime());
            world.AddTile(
                new Tile(
                    new TileBaseData(5, new Int2(40, 13), 2),
                    new TileRail(new[] { new Train(0.98829291305018363, 4, true, 3) }.ToImmutableList())));

            world.AddTile(new Tile(new TileBaseData(6, new Int2(40, 16), 3), new TileRailFork(ImmutableList<Train>.Empty, true)));

            world.MoveTrains(new DateTime() + TimeSpan.FromMilliseconds(100));
        }
    }
}
