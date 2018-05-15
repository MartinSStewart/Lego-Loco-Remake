using Common;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public interface IClientMessage
    {
    }

    public class AddTileMessage : IClientMessage
    {
        public Tile Tile { get; }

        public AddTileMessage(Tile tile)
        {
            Tile = tile;
        }
    }

    public class RemoveTileMessage : IClientMessage
    {
        public TileBaseData BaseData { get; }

        public RemoveTileMessage(TileBaseData baseData)
        {
            BaseData = baseData;
        }
    }

    public class ClickTileMessage : IClientMessage
    {
        public TileBaseData BaseData { get; }

        public ClickTileMessage(TileBaseData baseData)
        {
            BaseData = baseData;
        }
    }

    public class GetRegionMessage : IClientMessage
    {
        public Int2 SuperGridPosition { get; }

        public GetRegionMessage(Int2 superGridPosition)
        {
            SuperGridPosition = superGridPosition;
        }
    }

    public interface IServerMessage
    {
    }

    public class GotRegionMessage : IServerMessage
    {
        public Int2 SuperGridPosition { get; }
        public ImmutableList<Tile> Tiles { get; }

        public GotRegionMessage(Int2 superGridPosition, ImmutableList<Tile> tiles)
        {
            DebugEx.Assert(
                tiles.All(
                    item => World.GridToSuperGrid(item.BaseData.GridPosition).Equals(superGridPosition)));
            SuperGridPosition = superGridPosition;
            Tiles = tiles;
        }
    }

    public class AddedTileMessage : IServerMessage
    {
        public Tile Tile { get; }

        public AddedTileMessage(Tile tile)
        {
            Tile = tile;
        }
    }

    public class RemovedTileMessage : IServerMessage
    {
        public TileBaseData BaseData { get; }

        public RemovedTileMessage(TileBaseData baseData)
        {
            BaseData = baseData;
        }
    }

    public class ClickedTileMessage : IServerMessage
    {
        public TileBaseData BaseData { get; }

        public ClickedTileMessage(TileBaseData baseData)
        {
            BaseData = baseData;
        }
    }
}
