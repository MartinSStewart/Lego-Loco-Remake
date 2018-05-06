using Common;
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
        
        public const string Point2Type = "Point2";

        public static ImmutableDictionary<TileCategory, string> TileCategoryNames { get; } =
            new Dictionary<TileCategory, string>
            {
                [TileCategory.Buildings] = "Buildings",
                [TileCategory.Nature] = "Nature",
                [TileCategory.Roads] = "Roads"
            }.ToImmutableDictionary();

        static void Main(string[] args)
        {
            GenerateCodeToFiles();
        }

        public static void GenerateCodeToFiles()
        {
            var tileCategoryModule = "TileCategory";
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

            File.WriteAllText(Path.Combine(sourceDirectory, $"{tileCategoryModule}.elm"), GetTileCategoryCode(tileCategoryModule));
            File.WriteAllText(Path.Combine(sourceDirectory, $"{configModule}.elm"), configCode);
            File.WriteAllText(Path.Combine(sourceDirectory, $"{spriteModule}.elm"), spriteCode);
            File.WriteAllText(Path.Combine(sourceDirectory, $"{tileTypeModule}.elm"), tileTypeCode);
            File.WriteAllText(Path.Combine(sourceDirectory, $"{lensModule}.elm"), lensCode);
        }

        public static string HeaderAndModule(string moduleName) => $"{{- Auto generated code. -}}\n\n\nmodule {moduleName} exposing (..)\n";

        public static string GetTileCategoryCode(string moduleName) => 
$@"{HeaderAndModule(moduleName)}

type Category
    = {TileCategoryNames.Values.OrderBy(item => item).ToDelimitedString("\n    | ")}";

        public static string GetConfigCode(string moduleName)
        {
            string GetEnums<T>() =>
                Enum.GetValues(typeof(T))
                    .OfType<T>()
                    .Select(item => GetElmFunction(item.ToString().ToCamelCase(), "Int", Convert.ToInt32(item).ToString()))
                    .ToDelimitedString("\n\n");

            return
$@"{HeaderAndModule(moduleName)}
import Point2 exposing (Point2)


messageVersion : Int
messageVersion =
    0


{GetElmFunction(nameof(World.SuperGridSize).ToCamelCase(), "Int", World.SuperGridSize.ToString())}

{GetElmFunction(nameof(World.MinGridPosition).ToCamelCase(), $"{Point2Type} Int", World.MinGridPosition.X.ToString(), World.MinGridPosition.Y.ToString())}

{GetElmFunction(nameof(World.MaxGridPosition).ToCamelCase(), $"{Point2Type} Int", World.MaxGridPosition.X.ToString(), World.MaxGridPosition.Y.ToString())}

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
$@"{HeaderAndModule(moduleName)}
import Monocle.Lens as Lens exposing (Lens)


{codeBody}";
        }

        public static string GetElmFunction(string name, string type, params string[] parameters)
        {
            var isPrimitive = type == "Int" || type == "String" || type == "Float";
            var constructor = isPrimitive ? "" : type.Split(' ')[0] + " ";
            var returnLine = $"    {constructor}{parameters.ToDelimitedString(" ")}\n";
            var returnLineWithLineBreaks = $"    {constructor}{parameters.Select(item => "\n        " + item).ToDelimitedString("")}\n";
            return
                $"{name} : {type}\n" +
                $"{name} =\n" +
                (returnLine.Length <= 80 
                    ? returnLine 
                    : returnLineWithLineBreaks);
        }

        public static string GetSpriteCode(IEnumerable<Sprite> sprites, string moduleName)
        {
            var imageDirectory = Path.Combine(ClientDirectory, "public", "Images");

            var spriteCode = sprites
                .Select(sprite =>
                {
                    var imageSize = ImageSize(Path.Combine(imageDirectory, sprite.ImagePath));

                    var path = string.Join("/", new[] { "Images", sprite.ImagePath });
                    return GetElmFunction(
                        sprite.CodeName,
                        "Sprite",
                        $"\"{path}\"",
                        $"({Point2Type} {imageSize.X} {imageSize.Y})",
                        $"({Point2Type} {sprite.Origin.X} {sprite.Origin.Y})");
                })
                .ToDelimitedString("\n\n");

            return
$@"{HeaderAndModule(moduleName)}
import Point2 exposing ({Point2Type})
import Model exposing (Sprite)


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
                        $"({Point2Type} {tile.GridSize.X} {tile.GridSize.Y})",
                        "Sprite." + tile.ToolboxIconSprite,
                        TileCategoryNames[tile.Category],
                        tile.Data.GetElmParameter()))
                .ToDelimitedString("\n\n");

            return
$@"{HeaderAndModule(moduleName)}
import Sprite exposing (..)
import Point2 exposing ({Point2Type})
import Model exposing (..)
import TileCategory exposing (..)


{tileCode}

{tiles
    .Index()
    .Select(item =>
        $"{item.Value.CodeName}Id : Model.TileTypeId\n" +
        $"{item.Value.CodeName}Id =\n" +
        $"    Model.TileTypeId {item.Key}\n")
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
