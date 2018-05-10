module Cursor exposing (..)

import Model exposing (..)
import Html exposing (Html)
import Point2
import Html.Styled exposing (toUnstyled)
import Css
import Css.Foreign exposing (Snippet, global)
import Helpers
import Toybox


cursorView : Model -> Html msg
cursorView model =
    let
        gridPosition =
            Helpers.viewToGrid model.mousePosCurrent model

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
                        Helpers.collisionsAt gridPosition Point2.one model
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