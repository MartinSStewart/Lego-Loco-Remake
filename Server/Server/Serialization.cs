using Common;
using Common.TileData;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public static class Serialization
    {
        public enum MessageToClient { AddedTile, RemovedTile, GotRegion }
        public enum MessageToServer { AddTile, RemoveTile, GetRegion }

        public static MemoryStream GetWriteStream()
        {
            var stream = new MemoryStream();
            var version = 0;
            stream.WriteInt(version);
            return stream;
        }

        public static void Reply(this MemoryStream message) =>
            Convert.ToBase64String(message.ToArray());

        public static MemoryStream WriteInt2(this MemoryStream stream, Int2 int2) =>
            stream
                .WriteInt(int2.X)
                .WriteInt(int2.Y);

        public static MemoryStream WriteInt(this MemoryStream stream, int value)
        {
            stream.Write(BitConverter.GetBytes(value), 0, sizeof(int));
            return stream;
        }

        public static MemoryStream WriteBool(this MemoryStream stream, bool value)
        {
            stream.WriteByte(value ? (byte)1 : (byte)0);
            return stream;
        }

        public static MemoryStream WriteTile(this MemoryStream stream, Tile tile) => 
            stream
                .WriteInt((int)tile.TileTypeId)
                .WriteInt2(tile.GridPosition)
                .WriteInt(tile.Rotation)
                .WriteTileData(tile.Data);

        public static MemoryStream WriteTileData(this MemoryStream stream, ITileData tileData)
        {
            switch (tileData)
            {
                case TileBasic _:
                    return stream.WriteInt(0);
                case TileRail _:
                    return stream.WriteInt(1);
                case TileRailFork fork:
                    return stream
                        .WriteInt(2)
                        .WriteBool(fork.IsOn);
                default:
                    throw new NotImplementedException();
            }
        }

        public static MemoryStream WriteList<T>(this MemoryStream stream, ICollection<T> list, Func<MemoryStream, T, MemoryStream> writer)
        {
            stream.WriteInt(list.Count);
            foreach (var item in list)
            {
                writer(stream, item);
            }
            return stream;
        }

        public static MemoryStream WriteMessage(ICollection<IServerMessage> messages)
        {
            var stream = GetWriteStream();
            return stream.WriteList(messages, WriteServerAction);
        }

        public static MemoryStream WriteServerAction(this MemoryStream stream, IServerMessage message)
        {
            switch (message)
            {
                case AddedTileMessage msg:
                    return stream
                        .WriteInt((int)MessageToClient.AddedTile)
                        .WriteTile(msg.Tile);
                case RemovedTileMessage msg:
                    return stream
                        .WriteInt((int)MessageToClient.RemovedTile)
                        .WriteTile(msg.Tile);
                case GotRegionMessage msg:
                    return stream
                        .WriteInt((int)MessageToClient.GotRegion)
                        .WriteInt2(msg.TopLeft)
                        .WriteInt2(msg.GridSize)
                        .WriteList(msg.Tiles, WriteTile);
                default:
                    throw new NotImplementedException();
            }
        }

        public static List<IClientMessage> ReadMessage(this MemoryStream stream)
        {
            var version = stream.ReadInt();
            switch (version)
            {
                case 0:
                    return stream.ReadList(ReadClientAction);
                default:
                    throw new DecodeException();
            }
        }

        public static int ReadInt(this MemoryStream stream)
        {
            var size = sizeof(int);
            var buffer = new byte[size];
            var bytesRead = stream.Read(buffer, 0, size);
            if (bytesRead != size)
            {
                throw new DecodeException();
            }

            return BitConverter.ToInt32(buffer, 0);
        }

        public static bool ReadBool(this MemoryStream stream)
        {
            var size = sizeof(bool);
            var buffer = new byte[size];
            var bytesRead = stream.Read(buffer, 0, size);
            if (bytesRead != size)
            {
                throw new DecodeException();
            }

            switch (buffer[0])
            {
                case 0:
                    return false;
                case 1:
                    return true;
                default:
                    throw new DecodeException();
            }
        }

        public static Int2 ReadInt2(this MemoryStream stream)
        {
            var x = stream.ReadInt();
            var y = stream.ReadInt();
            return new Int2(x, y);
        }

        public static Tile ReadTile(this MemoryStream stream)
        {
            var tileId = stream.ReadInt();
            var gridPos = stream.ReadInt2();
            var rotation = stream.ReadInt();
            var tileData = stream.ReadTileData();
            return new Tile(tileId, gridPos, rotation, tileData);
        }

        public static ITileData ReadTileData(this MemoryStream stream)
        {
            var tileDataType = stream.ReadInt();
            switch (tileDataType)
            {
                case 0:
                    return new TileBasic();
                case 1:
                    return new TileRail();
                case 2:
                    return new TileRailFork(stream.ReadBool());
                default:
                    throw new NotImplementedException();
            }
        }

        public static List<T> ReadList<T>(this MemoryStream stream, Func<MemoryStream, T> reader)
        {
            var count = stream.ReadInt();
            var list = new List<T>(count);
            for (int i = 0; i < count; i++)
            {
                list.Add(reader(stream));
            }
            return list;
        }

        public static IClientMessage ReadClientAction(this MemoryStream stream)
        {
            var actionCode = stream.ReadInt();
            switch ((MessageToServer)actionCode)
            {
                case MessageToServer.AddTile:
                    {
                        var tile = ReadTile(stream);
                        return new AddTileMessage(tile);
                    }

                case MessageToServer.RemoveTile:
                    {
                        var tile = ReadTile(stream);
                        return new RemoveTileMessage(tile);
                    }
                case MessageToServer.GetRegion:
                    {
                        var topLeft = ReadInt2(stream);
                        var gridSize = ReadInt2(stream);
                        return new GetRegionMessage(topLeft, gridSize);
                    }
                default:
                    throw new NotImplementedException();
            }
        }
    }
}
