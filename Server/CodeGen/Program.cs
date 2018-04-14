using MoreLinq;
using Newtonsoft.Json;
using Server;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media.Imaging;

namespace CodeGen
{
    class Program
    {
        static void Main(string[] args)
        {
            var tiles = TileType.GetTileTypes();
            var sprites = Sprite.GetSprites();

            var imageDirectory = Path.Combine("..", "..", "..", "..", "Client", "public", "Images");
            var imagePaths = Directory.EnumerateFiles(imageDirectory, "*.png", SearchOption.AllDirectories).ToList();

            var repeatNames = sprites.GroupBy(item => item.CodeName).Where(item => item.Count() > 1);
            if (repeatNames.Any())
            {
                Console.WriteLine($"Sprites must all have unique names. The following names are used more than once:\n{repeatNames.Select(item => item.Key).ToDelimitedString(", ")}");
                Console.WriteLine("Press any key to close...");
                Console.Read();
            }

            string instanceFunc(string name, string type, params string[] parameters) =>
                $"{name} : {type}\n" +
                $"{name} =\n" +
                $"    {type} {parameters.ToDelimitedString(" ")}\n";

            var spriteCode = sprites.Select(sprite =>
                {
                    var size = ImageSize(Path.Combine(imageDirectory, sprite.ImagePath));

                    var path = string.Join("/", new[] { "Images", sprite.ImagePath });
                    return instanceFunc(
                        sprite.CodeName, 
                        "Sprite", 
                        $"\"/{path}\"", 
                        $"(Int2 {size.X} {size.Y})", 
                        $"(Int2 {sprite.Origin.X} {sprite.Origin.Y})");
                })
                .ToDelimitedString("\n\n");

            var tileCode = tiles.Select(tile =>
                instanceFunc(
                    tile.CodeName,
                    "TileType",
                    $"(Rot{tile.Sprites.Count} {tile.Sprites.Select(item => "Sprite." + item).ToDelimitedString(" ")})",
                    $"\"{tile.Name}\"",
                    $"(Int2 {tile.GridSize.X} {tile.GridSize.Y})",
                    "Sprite." + tile.ToolboxIconSprite))
                .ToDelimitedString("\n\n");

            var spriteModule = "Sprite";
            var code =
$@"{{- Auto generated code. -}}


module {spriteModule} exposing (..)

import Int2 exposing (Int2)


type alias Sprite =
    {{ filepath : String
    , pixelSize : Int2 --Exact dimensions of image.
    , pixelOffset : Int2
    }}


{spriteCode}";
            var tileModule = "Tile";
            var tileCodeAll = 
$@"{{- Auto generated code. -}}


module {tileModule} exposing (..)

import Int2 exposing (Int2)
import Sprite exposing (Sprite)


type alias TileType =
    {{ sprite: RotSprite
    , name : String
    , gridSize : Int2
    , icon : Sprite
    }}


type RotSprite
    = Rot1 Sprite
    | Rot2 Sprite Sprite
    | Rot4 Sprite Sprite Sprite Sprite


{tileCode}

tiles : List TileType
tiles = 
    [ {tiles.Select(item => item.CodeName).ToDelimitedString("\n    , ")}
    ]";

            File.WriteAllText(Path.Combine("..", "..", "..", "..", "Client", "src", $"{spriteModule}.elm"), code);
            File.WriteAllText(Path.Combine("..", "..", "..", "..", "Client", "src", $"{tileModule}.elm"), tileCodeAll);
        }

        public static Int2 ImageSize(string path)
        {
            using (var imageStream = File.OpenRead(path))
            {
                var decoder = BitmapDecoder.Create(imageStream, BitmapCreateOptions.IgnoreColorProfile, BitmapCacheOption.Default);
                var height = decoder.Frames[0].PixelHeight;
                var width = decoder.Frames[0].PixelWidth;
                return new Int2(width, height);
            }
        }
    }
}
