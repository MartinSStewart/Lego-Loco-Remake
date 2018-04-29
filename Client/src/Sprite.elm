{- Auto generated code. -}


module Sprite exposing (..)

import Int2 exposing (Int2)


type alias Sprite =
    { filepath : String
    , size : Int2 --Size of the sprite.
    , imageSize : Int2 --Exact dimensions of image.
    , origin : Int2
    }


sidewalk : Sprite
sidewalk =
    Sprite "/Images/sidewalk.png" (Int2 16 16) (Int2 16 16) (Int2 0 0)


grid : Sprite
grid =
    Sprite "/Images/grid.png" (Int2 16 16) (Int2 16 16) (Int2 0 0)


redHouse : Sprite
redHouse =
    Sprite "/Images/redHouse.png" (Int2 48 58) (Int2 48 58) (Int2 0 10)


redHouseIcon : Sprite
redHouseIcon =
    Sprite "/Images/redHouseIcon.png" (Int2 44 41) (Int2 44 41) (Int2 0 0)


roadHorizontal : Sprite
roadHorizontal =
    Sprite "/Images/roadHorizontal.png" (Int2 32 32) (Int2 32 32) (Int2 0 0)


roadVertical : Sprite
roadVertical =
    Sprite "/Images/roadVertical.png" (Int2 32 32) (Int2 32 32) (Int2 0 0)


roadTurnLeftUp : Sprite
roadTurnLeftUp =
    Sprite "/Images/roadTurnLeftUp.png" (Int2 32 32) (Int2 32 32) (Int2 0 0)


roadTurnLeftDown : Sprite
roadTurnLeftDown =
    Sprite "/Images/roadTurnLeftDown.png" (Int2 32 32) (Int2 32 32) (Int2 0 0)


roadTurnRightUp : Sprite
roadTurnRightUp =
    Sprite "/Images/roadTurnRightUp.png" (Int2 32 32) (Int2 32 32) (Int2 0 0)


roadTurnRightDown : Sprite
roadTurnRightDown =
    Sprite "/Images/roadTurnRightDown.png" (Int2 32 32) (Int2 32 32) (Int2 0 0)


toolbox : Sprite
toolbox =
    Sprite "/Images/toolbox.png" (Int2 180 234) (Int2 180 234) (Int2 0 0)


toolboxHandle : Sprite
toolboxHandle =
    Sprite "/Images/toolboxHandle.png" (Int2 70 37) (Int2 70 37) (Int2 0 18)


toolboxTileButtonDown : Sprite
toolboxTileButtonDown =
    Sprite "/Images/toolboxTileButtonDown.png" (Int2 54 54) (Int2 54 54) (Int2 0 0)


toolboxMenuButtonDown : Sprite
toolboxMenuButtonDown =
    Sprite "/Images/toolboxMenuButtonDown.png" (Int2 48 46) (Int2 48 46) (Int2 0 0)


toolboxMenuButtonUp : Sprite
toolboxMenuButtonUp =
    Sprite "/Images/toolboxMenuButtonUp.png" (Int2 48 46) (Int2 48 46) (Int2 0 0)


toolboxLeft : Sprite
toolboxLeft =
    Sprite "/Images/toolboxLeft.png" (Int2 165 234) (Int2 165 234) (Int2 0 0)


toolboxPlants : Sprite
toolboxPlants =
    Sprite "/Images/toolboxPlants.png" (Int2 28 31) (Int2 28 31) (Int2 0 0)


toolboxBomb : Sprite
toolboxBomb =
    Sprite "/Images/toolboxBomb.png" (Int2 25 28) (Int2 25 28) (Int2 0 0)


toolboxEraser : Sprite
toolboxEraser =
    Sprite "/Images/toolboxEraser.png" (Int2 31 27) (Int2 31 27) (Int2 0 0)


toolboxLeftArrow : Sprite
toolboxLeftArrow =
    Sprite "/Images/toolboxLeftArrow.png" (Int2 28 29) (Int2 28 29) (Int2 0 0)


toolboxRailroad : Sprite
toolboxRailroad =
    Sprite "/Images/toolboxRailroad.png" (Int2 28 18) (Int2 28 18) (Int2 0 0)


toolboxHouse : Sprite
toolboxHouse =
    Sprite "/Images/toolboxHouse.png" (Int2 28 35) (Int2 28 35) (Int2 0 0)
