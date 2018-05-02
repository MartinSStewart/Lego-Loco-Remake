using MoreLinq;
using Newtonsoft.Json;
using Server;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Media.Imaging;

namespace CodeGen
{
    public static class CodeGen
    {
        public static string ClientDirectory => Path.Combine("..", "..", "..", "..", "Client");
        public const string CodeHeader = "{- Auto generated code. -}\n\n";
        public const string Point2Type = "Point2";

        static void Main(string[] args)
        {
            GenerateCodeToFiles();
        }

        public static void GenerateCodeToFiles()
        {
            var configModule = "Config";
            var spriteModule = "Sprite";
            var tileTypeModule = "TileType";
            var lensModule = "Lenses";

            var sourceDirectory = Path.Combine(ClientDirectory, "src");

            var configCode = GetConfigCode(configModule);
            var spriteCode = GetSpriteCode(Sprite.GetSprites(), spriteModule);
            var tileTypeCode = GetTileTypeCode(TileType.GetTileTypes(), tileTypeModule);
            var lensCode = GetLensCode(
                new[]
                {
                    File.ReadAllText(Path.Combine(sourceDirectory, "Model.elm")),
                    File.ReadAllText(Path.Combine(sourceDirectory, "Toybox.elm")),
                    File.ReadAllText(Path.Combine(sourceDirectory, "Point2.elm")),
                    spriteCode,
                    tileTypeCode
                },
                lensModule);

            File.WriteAllText(Path.Combine(sourceDirectory, $"{configModule}.elm"), configCode);
            File.WriteAllText(Path.Combine(sourceDirectory, $"{spriteModule}.elm"), spriteCode);
            File.WriteAllText(Path.Combine(sourceDirectory, $"{tileTypeModule}.elm"), tileTypeCode);
            File.WriteAllText(Path.Combine(sourceDirectory, $"{lensModule}.elm"), lensCode);
        }

        public static string GetConfigCode(string moduleName)
        {
            string GetEnums<T>() =>
                Enum.GetValues(typeof(T))
                    .OfType<T>()
                    .Select(
                        item =>
                        {
                            var name = item.ToString().ToCamelCase();
                            return 
                                $"{name} : Int\n" +
                                $"{name} =\n" +
                                $"    {Convert.ToInt32(item)}\n";
                        })
                    .ToDelimitedString("\n\n");

            return
$@"{CodeHeader}
module {moduleName} exposing (..)


messageVersion : Int
messageVersion =
    0


superGridSize : Int
superGridSize =
    64


{GetEnums<Serialization.MessageToClient>()}

{GetEnums<Serialization.MessageToServer>()}";
        }

        public static string ToCamelCase(this string text) =>
            text.Length > 0
                ? char.ToLower(text[0]) + text.Substring(1)
                : text;

        public static string GetLensCode(IEnumerable<string> elmCode, string moduleName)
        {
            var text = elmCode
                .ToDelimitedString("")
                .Replace("\n", "")
                .Replace("\r", "")
                .Replace("\t", "");

            var typeAliasRegex = new Regex("type +alias +.*?}");

            var codeBody = typeAliasRegex
                .Matches(text)
                .OfType<Match>()
                .SelectMany(match =>
                {
                    var matchText = match.ToString();
                    var start = matchText.IndexOf('{') + 1;
                    var end = matchText.LastIndexOf('}');
                    return matchText
                        .Substring(start, end - start)
                        .Replace(" ", "")
                        .Split(',')
                        .Select(item => item.Split(':')[0]);
                })
                .Distinct()
                .OrderBy(item => item)
                .Select(item =>
                    $"{item} : Lens {{ b | {item} : a }} a\n" +
                    $"{item} =\n" +
                    $"    Lens .{item} (\\value item -> {{ item | {item} = value }})\n")
                .ToDelimitedString("\n\n");

            return
$@"{CodeHeader}
module {moduleName} exposing (..)

import Monocle.Lens as Lens exposing (Lens)


{codeBody}";
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
                    var imageSize = ImageSize(Path.Combine(imageDirectory, sprite.ImagePath));
                    var spriteSize = sprite.Size ?? imageSize;

                    var path = string.Join("/", new[] { "Images", sprite.ImagePath });
                    return GetElmFunction(
                        sprite.CodeName,
                        "Sprite",
                        $"\"{path}\"",
                        $"({Point2Type} {spriteSize.X} {spriteSize.Y})",
                        $"({Point2Type} {imageSize.X} {imageSize.Y})",
                        $"({Point2Type} {sprite.Origin.X} {sprite.Origin.Y})");
                })
                .ToDelimitedString("\n\n");

            return
$@"{CodeHeader}
module {moduleName} exposing (..)

import Point2 exposing ({Point2Type})


type alias Sprite =
    {{ filepath : String
    , size : {Point2Type} Int --Size of the sprite.
    , imageSize : {Point2Type} Int --Exact dimensions of image.
    , origin : {Point2Type} Int
    }}


{spriteCode}";
        }

        public static string GetTileTypeCode(IEnumerable<TileType> tiles, string moduleName)
        {
            var tileCategoryNames =
                new Dictionary<TileCategory, string>
                {
                    [TileCategory.Buildings] = "Buildings",
                    [TileCategory.Nature] = "Nature",
                    [TileCategory.Roads] = "Roads"
                };

            var tileCode = tiles
                .Select(tile =>
                    GetElmFunction(
                        tile.CodeName,
                        "TileType",
                        $"(Rot{tile.Sprites.Count} {tile.Sprites.Select(item => "Sprite." + item).ToDelimitedString(" ")})",
                        $"\"{tile.Name}\"",
                        $"({Point2Type} {tile.GridSize.X} {tile.GridSize.Y})",
                        "Sprite." + tile.ToolboxIconSprite,
                        tileCategoryNames[tile.Category]))
                .ToDelimitedString("\n\n");

            return
$@"{CodeHeader}
module {moduleName} exposing (..)

import Point2 exposing ({Point2Type})
import Sprite exposing (Sprite)


type alias TileType =
    {{ sprite : RotSprite
    , name : String
    , gridSize : {Point2Type} Int
    , icon : Sprite
    , category : Category
    }}


type RotSprite
    = Rot1 Sprite
    | Rot2 Sprite Sprite
    | Rot4 Sprite Sprite Sprite Sprite


type Category
    = {tileCategoryNames.Values.OrderBy(item => item).ToDelimitedString("\n    | ")}


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
