{- Auto generated code. -}


module Lenses exposing (..)

import Monocle.Lens as Lens exposing (Lens)


baseData : Lens { b | baseData : a } a
baseData =
    Lens .baseData (\value item -> { item | baseData = value })


category : Lens { b | category : a } a
category =
    Lens .category (\value item -> { item | category = value })


ctrlDown : Lens { b | ctrlDown : a } a
ctrlDown =
    Lens .ctrlDown (\value item -> { item | ctrlDown = value })


current : Lens { b | current : a } a
current =
    Lens .current (\value item -> { item | current = value })


currentRotation : Lens { b | currentRotation : a } a
currentRotation =
    Lens .currentRotation (\value item -> { item | currentRotation = value })


data : Lens { b | data : a } a
data =
    Lens .data (\value item -> { item | data = value })


drag : Lens { b | drag : a } a
drag =
    Lens .drag (\value item -> { item | drag = value })


editMode : Lens { b | editMode : a } a
editMode =
    Lens .editMode (\value item -> { item | editMode = value })


filepath : Lens { b | filepath : a } a
filepath =
    Lens .filepath (\value item -> { item | filepath = value })


gridSize : Lens { b | gridSize : a } a
gridSize =
    Lens .gridSize (\value item -> { item | gridSize = value })


icon : Lens { b | icon : a } a
icon =
    Lens .icon (\value item -> { item | icon = value })


lastTilePosition : Lens { b | lastTilePosition : a } a
lastTilePosition =
    Lens .lastTilePosition (\value item -> { item | lastTilePosition = value })


mousePosCurrent : Lens { b | mousePosCurrent : a } a
mousePosCurrent =
    Lens .mousePosCurrent (\value item -> { item | mousePosCurrent = value })


origin : Lens { b | origin : a } a
origin =
    Lens .origin (\value item -> { item | origin = value })


pendingGetRegions : Lens { b | pendingGetRegions : a } a
pendingGetRegions =
    Lens .pendingGetRegions (\value item -> { item | pendingGetRegions = value })


position : Lens { b | position : a } a
position =
    Lens .position (\value item -> { item | position = value })


rotationIndex : Lens { b | rotationIndex : a } a
rotationIndex =
    Lens .rotationIndex (\value item -> { item | rotationIndex = value })


size : Lens { b | size : a } a
size =
    Lens .size (\value item -> { item | size = value })


speed : Lens { b | speed : a } a
speed =
    Lens .speed (\value item -> { item | speed = value })


start : Lens { b | start : a } a
start =
    Lens .start (\value item -> { item | start = value })


t : Lens { b | t : a } a
t =
    Lens .t (\value item -> { item | t = value })


tileCategory : Lens { b | tileCategory : a } a
tileCategory =
    Lens .tileCategory (\value item -> { item | tileCategory = value })


tileId : Lens { b | tileId : a } a
tileId =
    Lens .tileId (\value item -> { item | tileId = value })


tiles : Lens { b | tiles : a } a
tiles =
    Lens .tiles (\value item -> { item | tiles = value })


toolbox : Lens { b | toolbox : a } a
toolbox =
    Lens .toolbox (\value item -> { item | toolbox = value })


viewPosition : Lens { b | viewPosition : a } a
viewPosition =
    Lens .viewPosition (\value item -> { item | viewPosition = value })


windowSize : Lens { b | windowSize : a } a
windowSize =
    Lens .windowSize (\value item -> { item | windowSize = value })


x : Lens { b | x : a } a
x =
    Lens .x (\value item -> { item | x = value })


y : Lens { b | y : a } a
y =
    Lens .y (\value item -> { item | y = value })
