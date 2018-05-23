using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using WebSocketSharp;
using WebSocketSharp.Server;
using Newtonsoft;
using Newtonsoft.Json.Linq;
using System.Collections.Immutable;
using Newtonsoft.Json;
using Common;
using Common.TileData;

namespace Server
{
    public static class Server
    {
        public static ConcurrentQueue<(string Id, IClientMessage Message)> MessageQueue { get; } = new ConcurrentQueue<(string, IClientMessage)>();

        public static World World { get; private set; } = 
            new World(TileType.GetTileTypes());

        /// <summary>
        /// Stands for Lego Loco Save.
        /// </summary>
        public const string SaveFileExtension = "lls";

        static void Main(string[] args)
        {
            RunServer().Wait();
        }

        public static async Task RunServer()
        {
            var socketServer = new WebSocketServer(5523);
            socketServer.AddWebSocketService("/socketservice", () => new SocketService());
            socketServer.Start();

            var autosavePath = "autosave." + SaveFileExtension;
            if (File.Exists(autosavePath))
            {
                var json = File.ReadAllText(autosavePath);
                try
                {
                    World = World.Load(TileType.GetTileTypes(), json);
                    Console.WriteLine("Autosave loaded.");
                }
                catch (JsonSerializationException)
                {
                    Console.WriteLine("Failed to load autosave.");
                }
            }

            await Task.Run(async () =>
            {
                var lastSave = DateTime.UtcNow;
                var stepSize = TimeSpan.FromMilliseconds(100);
                while (true)
                {
                    await Task.Delay(stepSize);
                    World.MoveTrains(stepSize);
                    while (MessageQueue.TryDequeue(out (string, IClientMessage) idAndMessage))
                    {
                        var (id, message) = idAndMessage;
                        switch (message)
                        {
                            case AddTileMessage msg:
                                World.AddTile(msg.Tile);

                                SendToEveryone(socketServer, new AddedTileMessage(msg.Tile));
                                break;
                            case RemoveTileMessage msg:
                                if (World.Remove(msg.BaseData))
                                {
                                    SendToEveryone(socketServer, new RemovedTileMessage(msg.BaseData));
                                }
                                break;
                            case ClickTileMessage msg:
                                if (World.ClickTile(msg.BaseData))
                                {
                                    SendToEveryone(socketServer, new ClickedTileMessage(msg.BaseData));
                                }
                                break;
                            case GetRegionMessage msg:
                                var region = World.GetRegion(msg.SuperGridPosition);

                                SendToUser(socketServer, id, new GotRegionMessage(msg.SuperGridPosition, region.ToImmutableList()));
                                break;
                            case GetTrainsMessage msg:
                                SendToUser(
                                    socketServer, 
                                    id, 
                                    new GotTrainsMessage(
                                        msg.SuperGridPosition, 
                                        World
                                            .GetRegion(msg.SuperGridPosition)
                                            .Where(tile => tile.Data is IRailTileData railData && railData.Trains.Any())
                                            .ToImmutableList()));
                                break;
                            default:
                                throw new NotImplementedException();
                        }
                    }

                    if (DateTime.UtcNow - lastSave > TimeSpan.FromMinutes(10))
                    {
                        if (File.Exists(autosavePath))
                        {
                            File.Copy(autosavePath, "autosave_backup." + SaveFileExtension, true);
                        }
                        File.WriteAllText(autosavePath, World.Save());
                        Console.WriteLine("World autosaved.");
                        lastSave = DateTime.UtcNow;
                    }
                }
            });
        }
         
        public static void SendToUser(WebSocketServer socketServer, string id, params IServerMessage[] message)
        {
            var byteArray = Serialization.WriteMessage(message).ToArray();
            var reply = Convert.ToBase64String(byteArray);
            Console.WriteLine(
                $"Sent: \n" +
                $"{JToken.FromObject(message).ToString()}\n");
            socketServer.WebSocketServices["/socketservice"].Sessions.SendToAsync(reply, id, _ => { });
        }

        public static void SendToEveryone(WebSocketServer socketServer, params IServerMessage[] message)
        {
            var byteArray = Serialization.WriteMessage(message).ToArray();
            var reply = Convert.ToBase64String(byteArray);
            Console.WriteLine(
                $"Sent: \n" +
                $"{JToken.FromObject(message).ToString()}\n");
            socketServer.WebSocketServices["/socketservice"].Sessions.BroadcastAsync(reply, () => { });
        }

        public class SocketService : WebSocketBehavior
        {
            protected override void OnOpen()
            {
                base.OnOpen();
            }

            protected override void OnError(WebSocketSharp.ErrorEventArgs e)
            {
                base.OnError(e);
            }

            protected override void OnMessage(MessageEventArgs e)
            {
                base.OnMessage(e);

                var msg = Convert.FromBase64String(e.Data);

                using (var stream = new MemoryStream(msg))
                {
                    try
                    {
                        var messages = stream.ReadMessage();
                        Console.WriteLine("Received: \n" + JToken.FromObject(messages).ToString());
                        foreach (var message in messages)
                        {
                            MessageQueue.Enqueue((ID, message));
                        }
                    }
                    catch (DecodeException)
                    {
                    }
                }
            }
        }
    }
}
