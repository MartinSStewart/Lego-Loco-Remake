module Model exposing (..)

import Point2 exposing (Point2)
import Mouse exposing (Position)


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
    }


type alias Tile =
    { tileId : Int
    , position : Point2 Int
    , rotationIndex : Int
    }


type alias Toybox =
    { viewPosition : Point2 Int -- Position of toolbox in view coordinates
    , drag : Maybe Drag
    }


type EditMode
    = PlaceTiles Int
    | Eraser


type ToolboxMsg
    = NoOp
    | DragStart (Point2 Int)
    | DragAt Mouse.Position
    | DragEnd (Point2 Int)
    | TileSelect Int
    | TileCategory Int
    | EraserSelect
    | BombSelect
    | Undo


type ToolboxCmd
    = None


type alias Drag =
    { start : Mouse.Position
    , current : Mouse.Position
    }
