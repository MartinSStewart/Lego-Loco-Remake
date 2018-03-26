using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
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
        public static ConcurrentQueue<Action> Queue { get; } = new ConcurrentQueue<Action>();

        public static int a = 0;

        public static World World { get; } = new World();

        static void Main(string[] args)
        {
            var socketServer = new WebSocketServer(5523);
            socketServer.AddWebSocketService("/socketservice", () => new SocketService());
            socketServer.Start();

            Console.ReadKey(true);
            socketServer.Stop();



        }

        public class SocketService : WebSocketBehavior
        {
            protected override void OnOpen()
            {
                base.OnOpen();
            }

            protected override void OnError(ErrorEventArgs e)
            {
                base.OnError(e);
            }

            protected override void OnMessage(MessageEventArgs e)
            {
                base.OnMessage(e);

                var message = Convert.ToBase64String(BitConverter.GetBytes(a++));
                SendAsync(message, result => Console.WriteLine(result + " " + message));
            }
        }
    }
}
