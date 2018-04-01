using System;
using System.Collections.Generic;
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
}
