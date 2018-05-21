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
        [TestCase(0.0)]
        [TestCase(0.5)]
        [TestCase(0.999999999999)]
        [TestCase(1.0)]
        [TestCase(1.000000000001)]
        [TestCase(1.4)]
        [TestCase(2)]
        [TestCase(2.6)]
        [TestCase(6)]
        public void MoveTrain(double trainSpeed)
        {
            var world = new World(TileType.GetTileTypes());

            var train = new Train(0, trainSpeed, true, 0);

            var trackLength = 5;
            for (var i = 0; i < trackLength; i++)
            {
                var tile = world.CreateFromName("railStraight", new Int2(i, 0), 0);
                if (i == 0)
                {
                    tile = tile.With(data: new TileRail(new[] { train }.ToImmutableList()));
                }
                world.AddTile(tile);
            }

            var startPos = world.GetTrainPosition(train.Id) ?? new Double2();

            world.MoveTrains(TimeSpan.FromSeconds(1));

            var endPos = world.GetTrainPosition(train.Id) ?? new Double2();

            Assert.AreEqual(startPos.X + Math.Min(trainSpeed, trackLength), endPos.X, 0.31);
            Assert.AreEqual(startPos.Y, endPos.Y, 0.0001);
        }
    }
}
