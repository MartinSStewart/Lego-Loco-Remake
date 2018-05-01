using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BuildClient
{
    class BuildClient
    {
        /// <summary>
        /// Root directory for the git repo.
        /// </summary>
        public static string RootDirectory => Path.Combine("..", "..", "..", "..");
        public static string ClientDirectory => Path.Combine(RootDirectory, "Client");
        public static string BuildDirectory => Path.Combine(ClientDirectory, "build");
        /// <summary>
        /// Directory Github uses for gh-pages.
        /// </summary>
        public static string GithubDocsDirectory => Path.Combine(RootDirectory, "docs");

        static void Main(string[] args)
        {
            var result = Common.Console.Run(ClientDirectory, new[] { "elm-app build" });
            Console.WriteLine(result);
            if (!result.Contains("Compiled successfully."))
            {
                Console.Read();
            }

            if (Directory.Exists(GithubDocsDirectory))
            {
                Directory.Delete(GithubDocsDirectory, true);
            }
            
            CopyDirectoryContents(BuildDirectory, GithubDocsDirectory);
        }

        public static void CopyDirectoryContents(string sourcePath, string destinationPath)
        {
            //Now Create all of the directories
            foreach (string dirPath in Directory.GetDirectories(sourcePath, "*",
                SearchOption.AllDirectories))
                Directory.CreateDirectory(dirPath.Replace(sourcePath, destinationPath));

            //Copy all the files & Replaces any files with the same name
            foreach (string newPath in Directory.GetFiles(sourcePath, "*.*",
                SearchOption.AllDirectories))
                File.Copy(newPath, newPath.Replace(sourcePath, destinationPath), true);
        }
    }
}
