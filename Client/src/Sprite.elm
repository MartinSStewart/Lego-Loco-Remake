{- Auto generated code. -}


module Sprite exposing (..)

import Point2 exposing (Point2)


type alias Sprite =
    { filepath : String
    , size : Point2 Int --Size of the sprite.
    , imageSize : Point2 Int --Exact dimensions of image.
    , origin : Point2 Int
    }


sidewalk : Sprite
sidewalk =
    Sprite "Images/sidewalk.png" (Point2 16 16) (Point2 16 16) (Point2 0 0)


grid : Sprite
grid =
    Sprite "Images/grid.png" (Point2 16 16) (Point2 16 16) (Point2 0 0)


redHouse : Sprite
redHouse =
    Sprite "Images/redHouse.png" (Point2 48 58) (Point2 48 58) (Point2 0 10)


redHouseIcon : Sprite
redHouseIcon =
    Sprite "Images/redHouseIcon.png" (Point2 44 41) (Point2 44 41) (Point2 0 0)


roadHorizontal : Sprite
roadHorizontal =
    Sprite "Images/roadHorizontal.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadVertical : Sprite
roadVertical =
    Sprite "Images/roadVertical.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadTurnLeftUp : Sprite
roadTurnLeftUp =
    Sprite "Images/roadTurnLeftUp.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadTurnLeftDown : Sprite
roadTurnLeftDown =
    Sprite "Images/roadTurnLeftDown.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadTurnRightUp : Sprite
roadTurnRightUp =
    Sprite "Images/roadTurnRightUp.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadTurnRightDown : Sprite
roadTurnRightDown =
    Sprite "Images/roadTurnRightDown.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


toolbox : Sprite
toolbox =
    Sprite "Images/toolbox.png" (Point2 180 234) (Point2 180 234) (Point2 0 0)


toolboxHandle : Sprite
toolboxHandle =
    Sprite "Images/toolboxHandle.png" (Point2 70 37) (Point2 70 37) (Point2 0 18)


toolboxTileButtonDown : Sprite
toolboxTileButtonDown =
    Sprite "Images/toolboxTileButtonDown.png" (Point2 54 54) (Point2 54 54) (Point2 0 0)


toolboxMenuButtonDown : Sprite
toolboxMenuButtonDown =
    Sprite "Images/toolboxMenuButtonDown.png" (Point2 48 46) (Point2 48 46) (Point2 0 0)


toolboxMenuButtonUp : Sprite
toolboxMenuButtonUp =
    Sprite "Images/toolboxMenuButtonUp.png" (Point2 48 46) (Point2 48 46) (Point2 0 0)


toolboxLeft : Sprite
toolboxLeft =
    Sprite "Images/toolboxLeft.png" (Point2 165 234) (Point2 165 234) (Point2 0 0)


toolboxPlants : Sprite
toolboxPlants =
    Sprite "Images/toolboxPlants.png" (Point2 28 31) (Point2 28 31) (Point2 0 0)


toolboxBomb : Sprite
toolboxBomb =
    Sprite "Images/toolboxBomb.png" (Point2 25 28) (Point2 25 28) (Point2 0 0)


toolboxEraser : Sprite
toolboxEraser =
    Sprite "Images/toolboxEraser.png" (Point2 31 27) (Point2 31 27) (Point2 0 0)


toolboxLeftArrow : Sprite
toolboxLeftArrow =
    Sprite "Images/toolboxLeftArrow.png" (Point2 28 29) (Point2 28 29) (Point2 0 0)


toolboxRailroad : Sprite
toolboxRailroad =
    Sprite "Images/toolboxRailroad.png" (Point2 28 18) (Point2 28 18) (Point2 0 0)


toolboxHouse : Sprite
toolboxHouse =
    Sprite "Images/toolboxHouse.png" (Point2 28 35) (Point2 28 35) (Point2 0 0)
