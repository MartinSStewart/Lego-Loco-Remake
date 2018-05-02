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


roadRailCrossingOpenHorizontal : Sprite
roadRailCrossingOpenHorizontal =
    Sprite "Images/roadRailCrossingOpenHorizontal.png" (Point2 48 32) (Point2 48 32) (Point2 0 0)


roadRailCrossingClosedHorizontal : Sprite
roadRailCrossingClosedHorizontal =
    Sprite "Images/roadRailCrossingClosedHorizontal.png" (Point2 48 32) (Point2 48 32) (Point2 0 0)


roadRailCrossingOpenVertical : Sprite
roadRailCrossingOpenVertical =
    Sprite "Images/roadRailCrossingOpenVertical.png" (Point2 32 48) (Point2 32 48) (Point2 0 0)


roadRailCrossingClosedVertical : Sprite
roadRailCrossingClosedVertical =
    Sprite "Images/roadRailCrossingClosedVertical.png" (Point2 32 48) (Point2 32 48) (Point2 0 0)


toyboxRight : Sprite
toyboxRight =
    Sprite "Images/toyboxRight.png" (Point2 180 234) (Point2 180 234) (Point2 0 0)


toyboxHandle : Sprite
toyboxHandle =
    Sprite "Images/toyboxHandle.png" (Point2 70 37) (Point2 70 37) (Point2 0 18)


toyboxTileButtonDown : Sprite
toyboxTileButtonDown =
    Sprite "Images/toyboxTileButtonDown.png" (Point2 54 54) (Point2 54 54) (Point2 0 0)


toyboxMenuButtonDown : Sprite
toyboxMenuButtonDown =
    Sprite "Images/toyboxMenuButtonDown.png" (Point2 48 46) (Point2 48 46) (Point2 0 0)


toyboxMenuButtonUp : Sprite
toyboxMenuButtonUp =
    Sprite "Images/toyboxMenuButtonUp.png" (Point2 48 46) (Point2 48 46) (Point2 0 0)


toyboxLeft : Sprite
toyboxLeft =
    Sprite "Images/toyboxLeft.png" (Point2 165 234) (Point2 165 234) (Point2 0 0)


toyboxPlants : Sprite
toyboxPlants =
    Sprite "Images/toyboxPlants.png" (Point2 28 31) (Point2 28 31) (Point2 0 0)


toyboxBomb : Sprite
toyboxBomb =
    Sprite "Images/toyboxBomb.png" (Point2 25 28) (Point2 25 28) (Point2 0 0)


toyboxEraser : Sprite
toyboxEraser =
    Sprite "Images/toyboxEraser.png" (Point2 31 27) (Point2 31 27) (Point2 0 0)


toyboxLeftArrow : Sprite
toyboxLeftArrow =
    Sprite "Images/toyboxLeftArrow.png" (Point2 28 29) (Point2 28 29) (Point2 0 0)


toyboxRailroad : Sprite
toyboxRailroad =
    Sprite "Images/toyboxRailroad.png" (Point2 28 18) (Point2 28 18) (Point2 0 0)


toyboxHouse : Sprite
toyboxHouse =
    Sprite "Images/toyboxHouse.png" (Point2 28 35) (Point2 28 35) (Point2 0 0)
