module Cursor exposing (..)

import Css
import Css.Foreign exposing (Snippet, global)
import Html exposing (Html)
import Html.Styled exposing (toUnstyled)
import Model exposing (..)
import Point2
import Tile
import Toybox
import Grid


cursorView : Model -> Html msg
cursorView model =
    let
        gridPosition =
            Tile.viewToGrid model.mousePosCurrent model.viewPosition

        cursor =
            if model.toolbox.drag /= Nothing then
                Css.grabbing
            else if Toybox.insideHandle model.windowSize model.mousePosCurrent model.toolbox then
                Css.grab
            else
                case model.editMode of
                    PlaceTiles tileTypeId ->
                        Css.default

                    Eraser ->
                        Css.default

                    Hand ->
                        Grid.collisionsAt gridPosition Point2.one model.tiles
                            |> List.head
                            |> Maybe.map
                                (\tile ->
                                    case tile.data of
                                        TileBasic ->
                                            Css.default

                                        Model.TileRail _ ->
                                            Css.default

                                        Model.TileRailFork _ _ ->
                                            Css.pointer

                                        Model.TileDepot _ _ ->
                                            Css.pointer
                                )
                            |> Maybe.withDefault Css.default
    in
        Css.Foreign.global
            [ Css.Foreign.html
                [ Css.cursor cursor ]
            ]
            |> toUnstyled
