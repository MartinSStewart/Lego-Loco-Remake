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
        public static string ClientDirectory => Path.Combine("..", "..", "..", "..", "Client");

        static void Main(string[] args)
        {
            var spriteModule = "Sprite";
            var tileTypeModule = "TileType";

            var spriteCode = GetSpriteCode(Sprite.GetSprites(), spriteModule);
            var tileTypeCode = GetTileTypeCode(TileType.GetTileTypes(), tileTypeModule);

            File.WriteAllText(Path.Combine(ClientDirectory, "src", $"{spriteModule}.elm"), spriteCode);
            File.WriteAllText(Path.Combine(ClientDirectory, "src", $"{tileTypeModule}.elm"), tileTypeCode);
        }

        public static string GetElmFunction(string name, string type, params string[] parameters) =>
            $"{name} : {type}\n" +
            $"{name} =\n" +
            $"    {type} {parameters.ToDelimitedString(" ")}\n";

        public static string GetSpriteCode(IEnumerable<Sprite> sprites, string moduleName)
        {
            var imageDirectory = Path.Combine(ClientDirectory, "public", "Images");

            var spriteCode = sprites
                .Select(sprite =>
                {
                    var size = ImageSize(Path.Combine(imageDirectory, sprite.ImagePath));

                    var path = string.Join("/", new[] { "Images", sprite.ImagePath });
                    return GetElmFunction(
                        sprite.CodeName,
                        "Sprite",
                        $"\"/{path}\"",
                        $"(Int2 {size.X} {size.Y})",
                        $"(Int2 {sprite.Origin.X} {sprite.Origin.Y})");
                })
                .ToDelimitedString("\n\n");

            return
$@"{{- Auto generated code. -}}


module {moduleName} exposing (..)

import Int2 exposing (Int2)


type alias Sprite =
    {{ filepath : String
    , pixelSize : Int2 --Exact dimensions of image.
    , pixelOffset : Int2
    }}


{spriteCode}";
        }

        public static string GetTileTypeCode(IEnumerable<TileType> tiles, string moduleName)
        {
            var tileCode = tiles
                .Select(tile =>
                    GetElmFunction(
                        tile.CodeName,
                        "TileType",
                        $"(Rot{tile.Sprites.Count} {tile.Sprites.Select(item => "Sprite." + item).ToDelimitedString(" ")})",
                        $"\"{tile.Name}\"",
                        $"(Int2 {tile.GridSize.X} {tile.GridSize.Y})",
                        "Sprite." + tile.ToolboxIconSprite))
                .ToDelimitedString("\n\n");

            return
$@"{{- Auto generated code. -}}


module {moduleName} exposing (..)

import Int2 exposing (Int2)
import Sprite exposing (Sprite)


type alias TileType =
    {{ sprite : RotSprite
    , name : String
    , gridSize : Int2
    , icon : Sprite
    }}


type RotSprite
    = Rot1 Sprite
    | Rot2 Sprite Sprite
    | Rot4 Sprite Sprite Sprite Sprite


{tileCode}

{tiles
    .Index()
    .Select(item =>
        $"{item.Value.CodeName}Index : Int\n" +
        $"{item.Value.CodeName}Index =\n" +
        $"    {item.Key}\n")
    .ToDelimitedString("\n\n")}

tiles : List TileType
tiles = 
    [ {tiles.Select(item => item.CodeName).ToDelimitedString("\n    , ")}
    ]";
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
