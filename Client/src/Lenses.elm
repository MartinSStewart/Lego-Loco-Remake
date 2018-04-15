{- Auto generated code. -}


module Lenses exposing (..)

import Monocle.Lens as Lens exposing (Lens)


viewPosition : Lens { b | viewPosition : a } a
viewPosition =
    Lens .viewPosition (\value item -> { item | viewPosition = value })


viewSize : Lens { b | viewSize : a } a
viewSize =
    Lens .viewSize (\value item -> { item | viewSize = value })


tiles : Lens { b | tiles : a } a
tiles =
    Lens .tiles (\value item -> { item | tiles = value })


toolbox : Lens { b | toolbox : a } a
toolbox =
    Lens .toolbox (\value item -> { item | toolbox = value })


currentTile : Lens { b | currentTile : a } a
currentTile =
    Lens .currentTile (\value item -> { item | currentTile = value })


currentRotation : Lens { b | currentRotation : a } a
currentRotation =
    Lens .currentRotation (\value item -> { item | currentRotation = value })


lastTilePosition : Lens { b | lastTilePosition : a } a
lastTilePosition =
    Lens .lastTilePosition (\value item -> { item | lastTilePosition = value })


mousePosCurrent : Lens { b | mousePosCurrent : a } a
mousePosCurrent =
    Lens .mousePosCurrent (\value item -> { item | mousePosCurrent = value })


windowSize : Lens { b | windowSize : a } a
windowSize =
    Lens .windowSize (\value item -> { item | windowSize = value })


tileId : Lens { b | tileId : a } a
tileId =
    Lens .tileId (\value item -> { item | tileId = value })


position : Lens { b | position : a } a
position =
    Lens .position (\value item -> { item | position = value })


rotationIndex : Lens { b | rotationIndex : a } a
rotationIndex =
    Lens .rotationIndex (\value item -> { item | rotationIndex = value })


selectedTileId : Lens { b | selectedTileId : a } a
selectedTileId =
    Lens .selectedTileId (\value item -> { item | selectedTileId = value })


drag : Lens { b | drag : a } a
drag =
    Lens .drag (\value item -> { item | drag = value })


start : Lens { b | start : a } a
start =
    Lens .start (\value item -> { item | start = value })


current : Lens { b | current : a } a
current =
    Lens .current (\value item -> { item | current = value })


filepath : Lens { b | filepath : a } a
filepath =
    Lens .filepath (\value item -> { item | filepath = value })


pixelSize : Lens { b | pixelSize : a } a
pixelSize =
    Lens .pixelSize (\value item -> { item | pixelSize = value })


pixelOffset : Lens { b | pixelOffset : a } a
pixelOffset =
    Lens .pixelOffset (\value item -> { item | pixelOffset = value })


sprite : Lens { b | sprite : a } a
sprite =
    Lens .sprite (\value item -> { item | sprite = value })


name : Lens { b | name : a } a
name =
    Lens .name (\value item -> { item | name = value })


gridSize : Lens { b | gridSize : a } a
gridSize =
    Lens .gridSize (\value item -> { item | gridSize = value })


icon : Lens { b | icon : a } a
icon =
    Lens .icon (\value item -> { item | icon = value })
