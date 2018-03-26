module Tests exposing (..)

import Test exposing (..)
import Expect
import Int2 exposing (..)
import Server exposing (..)
import BinaryBase64
import Model exposing (collidesWith, Tile)


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
                collidesWith (Tile 0 0 (Int2 0 0)) (Tile 0 0 (Int2 0 0))
                    |> Expect.equal True
        , test "Tiles next to eachother should not collide." <|
            \_ ->
                collidesWith (Tile 0 0 (Int2 0 0)) (Tile 0 0 (Int2 3 0))
                    |> Expect.equal False
        , test "Tiles overlapping should collide." <|
            \_ ->
                collidesWith (Tile 0 0 (Int2 0 0)) (Tile 0 0 (Int2 2 -2))
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
        , test "Decode int" <|
            \_ -> BinaryBase64.decode "HgAAAA==" |> Expect.equal (Ok [ 30, 0, 0, 0 ])
        , test "ReadInt" <|
            \_ -> Server.readInt [ 30, 0, 0, 0 ] |> Expect.equal (Just 30)
        , test "ReadUInt" <|
            \_ -> Server.readUInt [ 30, 0, 0, 0 ] |> Expect.equal (Just 30)
        , test "ReadUInt fails to parse" <|
            \_ -> Server.readUInt [ 30, 0, 0 ] |> Expect.equal Nothing
        ]
