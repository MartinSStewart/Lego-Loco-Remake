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
    Sprite "%PUBLIC_URL%/Images/sidewalk.png" (Point2 16 16) (Point2 16 16) (Point2 0 0)


grid : Sprite
grid =
    Sprite "%PUBLIC_URL%/Images/grid.png" (Point2 16 16) (Point2 16 16) (Point2 0 0)


redHouse : Sprite
redHouse =
    Sprite "%PUBLIC_URL%/Images/redHouse.png" (Point2 48 58) (Point2 48 58) (Point2 0 10)


redHouseIcon : Sprite
redHouseIcon =
    Sprite "%PUBLIC_URL%/Images/redHouseIcon.png" (Point2 44 41) (Point2 44 41) (Point2 0 0)


roadHorizontal : Sprite
roadHorizontal =
    Sprite "%PUBLIC_URL%/Images/roadHorizontal.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadVertical : Sprite
roadVertical =
    Sprite "%PUBLIC_URL%/Images/roadVertical.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadTurnLeftUp : Sprite
roadTurnLeftUp =
    Sprite "%PUBLIC_URL%/Images/roadTurnLeftUp.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadTurnLeftDown : Sprite
roadTurnLeftDown =
    Sprite "%PUBLIC_URL%/Images/roadTurnLeftDown.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadTurnRightUp : Sprite
roadTurnRightUp =
    Sprite "%PUBLIC_URL%/Images/roadTurnRightUp.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


roadTurnRightDown : Sprite
roadTurnRightDown =
    Sprite "%PUBLIC_URL%/Images/roadTurnRightDown.png" (Point2 32 32) (Point2 32 32) (Point2 0 0)


toolbox : Sprite
toolbox =
    Sprite "%PUBLIC_URL%/Images/toolbox.png" (Point2 180 234) (Point2 180 234) (Point2 0 0)


toolboxHandle : Sprite
toolboxHandle =
    Sprite "%PUBLIC_URL%/Images/toolboxHandle.png" (Point2 70 37) (Point2 70 37) (Point2 0 18)


toolboxTileButtonDown : Sprite
toolboxTileButtonDown =
    Sprite "%PUBLIC_URL%/Images/toolboxTileButtonDown.png" (Point2 54 54) (Point2 54 54) (Point2 0 0)


toolboxMenuButtonDown : Sprite
toolboxMenuButtonDown =
    Sprite "%PUBLIC_URL%/Images/toolboxMenuButtonDown.png" (Point2 48 46) (Point2 48 46) (Point2 0 0)


toolboxMenuButtonUp : Sprite
toolboxMenuButtonUp =
    Sprite "%PUBLIC_URL%/Images/toolboxMenuButtonUp.png" (Point2 48 46) (Point2 48 46) (Point2 0 0)


toolboxLeft : Sprite
toolboxLeft =
    Sprite "%PUBLIC_URL%/Images/toolboxLeft.png" (Point2 165 234) (Point2 165 234) (Point2 0 0)


toolboxPlants : Sprite
toolboxPlants =
    Sprite "%PUBLIC_URL%/Images/toolboxPlants.png" (Point2 28 31) (Point2 28 31) (Point2 0 0)


toolboxBomb : Sprite
toolboxBomb =
    Sprite "%PUBLIC_URL%/Images/toolboxBomb.png" (Point2 25 28) (Point2 25 28) (Point2 0 0)


toolboxEraser : Sprite
toolboxEraser =
    Sprite "%PUBLIC_URL%/Images/toolboxEraser.png" (Point2 31 27) (Point2 31 27) (Point2 0 0)


toolboxLeftArrow : Sprite
toolboxLeftArrow =
    Sprite "%PUBLIC_URL%/Images/toolboxLeftArrow.png" (Point2 28 29) (Point2 28 29) (Point2 0 0)


toolboxRailroad : Sprite
toolboxRailroad =
    Sprite "%PUBLIC_URL%/Images/toolboxRailroad.png" (Point2 28 18) (Point2 28 18) (Point2 0 0)


toolboxHouse : Sprite
toolboxHouse =
    Sprite "%PUBLIC_URL%/Images/toolboxHouse.png" (Point2 28 35) (Point2 28 35) (Point2 0 0)
