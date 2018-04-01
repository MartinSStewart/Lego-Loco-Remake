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

namespace Server
{
    class Program
    {
        public static ConcurrentQueue<(string Id, IClientMessage Message)> MessageQueue { get; } = new ConcurrentQueue<(string, IClientMessage)>();

        public static World World { get; } = new World();

        static void Main(string[] args)
        {
            var socketServer = new WebSocketServer(5523);
            socketServer.AddWebSocketService("/socketservice", () => new SocketService());
            socketServer.Start();

            World.AddTile(new Tile(0, new Int2(), 0));
            
            Task.Run(async () =>
            {
                while (true)
                {
                    await Task.Delay(10);
                    foreach (var item in MessageQueue)
                    {
                        var (id, message) = item;
                        switch (message)
                        {
                            case AddTileMessage msg:
                                World.AddTile(msg.Tile);
                                break;
                            case RemoveTileMessage msg:
                                World.Remove(msg.Tile);
                                break;
                            case GetRegionMessage msg:
                                var region = World.GetRegion(msg.TopLeft, msg.GridSize);
                                
                                var reply = Convert.ToBase64String(Serialization.GetWriteStream()
                                    .WriteInt2(msg.TopLeft)
                                    .WriteInt2(msg.GridSize)
                                    .WriteList(region.ToArray(), Serialization.WriteTile)
                                    .ToArray());
                                socketServer.WebSocketServices["/socketservice"].Sessions.SendToAsync(reply, id, _ => { });
                                break;
                            default:
                                throw new Exception("Unhandled case.");
                        }
                    }
                }
            });

            Console.ReadKey(true);
            socketServer.Stop();
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
