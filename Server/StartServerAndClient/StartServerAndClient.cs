using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StartServerAndClient
{
    class StartServerAndClient
    {
        /// <summary>
        /// Root directory for the git repo.
        /// </summary>
        public static string RootDirectory => Path.Combine("..", "..", "..", "..");
        public static string ClientDirectory => Path.Combine(RootDirectory, "Client");

        static void Main(string[] args)
        {
            //var cmd = Common.Console.RunInConsole(ClientDirectory, new[] { "elm-app start" });
            Server.Server.RunServer();
            Console.Read();

            //cmd.Close();
        }
    }
}
