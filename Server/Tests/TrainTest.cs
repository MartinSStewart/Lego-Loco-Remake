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
        [Test]
        public void MoveTrain()
        {
            var world = new World(TileType.GetTileTypes());

            var train = new Train(0, 1, true, 0);
            for (var i = 0; i < 5; i++)
            {
                var tile = world.CreateFromName("railStraight", new Int2(i, 0), 0);
                if (i == 0)
                {
                    tile = tile.With(data: new TileRail(new[] { train }.ToImmutableList()));
                }
                world.AddTile(tile);
            }

            world.MoveTrains(TimeSpan.FromSeconds(1));
        }
    }
}
