module Model exposing (..)

import Point2 exposing (Point2)
import Mouse exposing (Position)
import TileCategory exposing (..)
import Dict exposing (Dict)
import Set exposing (Set)


type alias Model =
    { viewPosition : Point2 Int -- Position of view in pixel coordinates.
    , tiles : Grid
    , toolbox : Toybox
    , currentRotation : Int
    , lastTilePosition : Maybe (Point2 Int) -- Position of the last place tile.
    , mousePosCurrent : Mouse.Position
    , windowSize : Point2 Int
    , editMode : EditMode
    , ctrlDown : Bool
    , pendingGetRegions : Set ( Int, Int )
    }


type alias Grid =
    Dict ( Int, Int ) (List Tile)


type alias Sprite =
    { filepath : String
    , size : Point2 Int --Exact dimensions of image.
    , origin : Point2 Int
    }


type alias Tile =
    { baseData : TileBaseData
    , data : TileData
    }


type alias TileBaseData =
    { tileId : TileTypeId
    , position : Point2 Int
    , rotationIndex : Int
    }


type alias TileType =
    { gridSize : Point2 Int
    , icon : Sprite
    , category : Category
    , data : TileTypeData
    }


type Rot a
    = Rot1 a
    | Rot2 a a
    | Rot4 a a a a


type TileData
    = TileBasic
    | TileRail (List Train)
    | TileRailFork (List Train) Bool -- Is on
    | TileDepot (List Train) Bool -- Is occupied


type TileTypeData
    = Basic (Rot Sprite)
    | Rail (Rot Sprite) (Float -> Point2 Float)
    | RailFork (Rot ( Sprite, Sprite )) (Float -> Point2 Float) (Float -> Point2 Float)
    | Depot (Rot ( Sprite, Sprite, Sprite ))


type TileTypeId
    = TileTypeId Int


type alias Train =
    { t : Float -- The distance along the current rail path where 0 == start and 1 == end.
    , speed : Float -- In grid units per second. Positive means moving in the direction the train is facing.
    , facingEnd : Bool -- If true, the train is pointing towards the path end.
    , id : TrainId
    }


type TrainId
    = TrainId Int


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
    | HandSelect
    | Undo


type ToolboxCmd
    = None


type alias Drag =
    { start : Mouse.Position
    , current : Mouse.Position
    }
