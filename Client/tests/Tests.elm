module Tests exposing (..)

import Test exposing (..)
import Expect
import Int2 exposing (..)
import Main exposing (..)


-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!


all : Test
all =
    describe "A Test Suite"
        [ test "Addition" <|
            \_ ->
                Expect.equal 10 (3 + 7)
        , test "String.left" <|
            \_ ->
                Expect.equal "a" (String.left 1 "abcdefg")
        , test "Tiles right on top of eachother should collide." <|
            \_ ->
                collidesWith (TileInstance 0 (Int2 0 0)) (TileInstance 0 (Int2 0 0))
                    |> Expect.equal True
        , test "Tiles next to eachother should not collide." <|
            \_ ->
                collidesWith (TileInstance 0 (Int2 0 0)) (TileInstance 0 (Int2 3 0))
                    |> Expect.equal False
        , test "Tiles overlapping should collide." <|
            \_ ->
                collidesWith (TileInstance 0 (Int2 0 0)) (TileInstance 0 (Int2 2 -2))
                    |> Expect.equal True
        , test "Rectangles next to eachother should not collide." <|
            \_ ->
                rectangleCollision (Int2 0 0) (Int2 3 3) (Int2 3 0) (Int2 3 3)
                    |> Expect.equal False
        , test "Point outside rectangle." <|
            \_ ->
                pointInsideRectangle (Int2 0 0) (Int2 3 3) (Int2 3 0)
                    |> Expect.equal False
        , test "Point inside rectangle." <|
            \_ ->
                pointInsideRectangle (Int2 0 0) (Int2 3 3) (Int2 2 0)
                    |> Expect.equal True
        ]
