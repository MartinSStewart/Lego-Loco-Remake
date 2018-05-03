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
        public Tile Tile { get; }

        public RemoveTileMessage(Tile tile)
        {
            Tile = tile;
        }
    }

    public class GetRegionMessage : IClientMessage
    {
        public Int2 TopLeft { get; }
        public Int2 GridSize { get; }

        public GetRegionMessage(Int2 topLeft, Int2 gridSize)
        {
            TopLeft = topLeft;
            GridSize = gridSize;
        }
    }

    public interface IServerMessage
    {
    }

    public class GotRegionMessage : IServerMessage
    {
        public Int2 TopLeft { get; }
        public Int2 GridSize { get; }
        public ImmutableList<Tile> Tiles { get; }

        public GotRegionMessage(Int2 topLeft, Int2 gridSize, ImmutableList<Tile> tiles)
        {
            TopLeft = topLeft;
            GridSize = gridSize;
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
        public Tile Tile { get; }

        public RemovedTileMessage(Tile tile)
        {
            Tile = tile;
        }
    }
}
