module Model exposing (..)

import Point2 exposing (Point2)
import Mouse exposing (Position)
import TileCategory exposing (..)


type alias Model =
    { viewPosition : Point2 Int -- Position of view in pixel coordinates.
    , viewSize : Point2 Int -- Size of view in pixel coordinates.
    , tiles : List Tile
    , toolbox : Toybox
    , currentTile : Maybe (Point2 Int)
    , currentRotation : Int
    , lastTilePosition : Maybe (Point2 Int)
    , mousePosCurrent : Mouse.Position
    , windowSize : Point2 Int
    , editMode : EditMode
    , ctrlDown : Bool
    }


type alias Sprite =
    { filepath : String
    , size : Point2 Int --Exact dimensions of image.
    , origin : Point2 Int
    }


type alias Tile =
    { tileId : TileTypeId
    , position : Point2 Int
    , rotationIndex : Int
    , data : TileData
    }


type alias TileType =
    { sprite : RotSprite
    , gridSize : Point2 Int
    , icon : Sprite
    , category : Category
    , data : TileTypeData
    }


type RotSprite
    = Rot1 Sprite
    | Rot2 Sprite Sprite
    | Rot4 Sprite Sprite Sprite Sprite


type TileData
    = TileBasic
    | TileRail
    | TileRailFork Bool


type TileTypeData
    = Basic
    | Rail (Float -> Point2 Float)
    | RailFork (Float -> Point2 Float) (Float -> Point2 Float)


type TileTypeId
    = TileTypeId Int


type alias Toybox =
    { viewPosition : Point2 Int -- Position of toolbox in view coordinates
    , drag : Maybe Drag
    , tileCategory : Maybe Category
    }


type EditMode
    = PlaceTiles TileTypeId
    | Eraser
    | Hand


type ToolboxMsg
    = NoOp
    | DragStart (Point2 Int)
    | DragAt Mouse.Position
    | DragEnd (Point2 Int)
    | TileSelect TileTypeId
    | TileCategory (Maybe Category)
    | EraserSelect
    | BombSelect
    | HandSelect
    | Undo


type ToolboxCmd
    = None


type alias Drag =
    { start : Mouse.Position
    , current : Mouse.Position
    }
