using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SpriteGen
{
    public static class SpriteGen
    {
        static void Main(string[] args)
        {
            var resourceDirectory = "Resource";

            Console.WriteLine($"Enter path to Lego Loco \"{resourceDirectory}\" directory (Should appear after running LOCORFTOOL.exe):");

            var cachedPathFile = "CachedPath.txt";
            var cachedPath = "";
            if (File.Exists(cachedPathFile))
            {
                cachedPath = File.ReadAllText(cachedPathFile);
                Console.WriteLine("...or press enter to reuse " + cachedPath);
            }

            var input = Console.ReadLine();
            var path = input == "" ? cachedPath : input;

            var resourcePath = Path.Combine(path, resourceDirectory);
            if (Directory.Exists(resourcePath))
            {
                File.WriteAllText("CachedPath.txt", path);

                var jarFile = "locodecomp.jar";
                //Directory.CreateDirectory("Images");
                //var movedJarFile = Path.Combine("Images", jarFile);
                //File.Copy(jarFile, movedJarFile);

                var imagesPath = Path.Combine(Environment.CurrentDirectory, "Images");

                var folders = new[] { "roads", "scenery", "building", "toybox", "track" };

                Parallel.ForEach(
                    folders.SelectMany(item => Directory.EnumerateFiles(Path.Combine(resourcePath, item), "*.bmp", SearchOption.AllDirectories)), 
                    new ParallelOptions { MaxDegreeOfParallelism = 20 },
                    sourceBmpPath =>
                    {
                        var bmpFileName = Path.GetFileName(sourceBmpPath);

                        var workingDirectory = Path.Combine(
                            imagesPath, 
                            Path.Combine(
                                sourceBmpPath
                                    .SplitPath()
                                    .WithoutLast()
                                    .SkipWhile(item => item != resourceDirectory)
                                    .Skip(1)
                                    .ToArray()));

                        var destinationBmpPath = Path.Combine(workingDirectory, bmpFileName);
                        var destinationPngPath = Path.Combine(workingDirectory, Path.ChangeExtension(bmpFileName, "png"));

                        if (File.Exists(destinationPngPath))
                        {
                            return;
                        }

                        Directory.CreateDirectory(workingDirectory);
                        File.Copy(sourceBmpPath, destinationBmpPath, true);

                        Common.Console.Run(
                            workingDirectory, 
                            new[] { $"java -jar {Path.Combine(Environment.CurrentDirectory, jarFile)} {sourceBmpPath} {bmpFileName}", "y" });

                        try
                        {
                            using (var img = Image.FromFile(sourceBmpPath))
                            using (var bitmap = new Bitmap(img))
                            {
                                for (int x = 0; x < bitmap.Width; x++)
                                {
                                    for (int y = 0; y < bitmap.Height; y++)
                                    {
                                        if (bitmap.GetPixel(x, y) == Color.FromArgb(255, 0, 255))
                                        {
                                            bitmap.SetPixel(x, y, Color.FromArgb(0, 0, 0, 0));
                                        }
                                    }
                                }
                                bitmap.Save(destinationPngPath);
                            }

                            try
                            {
                                File.Delete(Path.Combine(workingDirectory, bmpFileName));
                            }
                            catch (IOException)
                            {
                            }
                        }
                        catch (OutOfMemoryException)
                        {
                        }

                        try
                        {
                            File.Delete(Path.Combine(workingDirectory, bmpFileName + ".raw"));
                        }
                        catch (IOException)
                        {
                        }

                        
                    });
            }
            else
            {
                Console.WriteLine($"Could not find \"{resourceDirectory}\" directory in the provided path.");
            }

            Console.WriteLine("Press any key to close...");
            Console.Read();
        }

        public static string[] SplitPath(this string path) => path.Split(new[] { '\\', '/' }, StringSplitOptions.RemoveEmptyEntries);

        /// <remarks>Original code found here: https://stackoverflow.com/a/4166561 </remarks>
        public static IEnumerable<T> WithoutLast<T>(this IEnumerable<T> source)
        {
            using (var e = source.GetEnumerator())
            {
                if (e.MoveNext())
                {
                    for (var value = e.Current; e.MoveNext(); value = e.Current)
                    {
                        yield return value;
                    }
                }
            }
        }
    }
}
