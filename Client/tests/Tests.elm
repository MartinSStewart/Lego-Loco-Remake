module Tests exposing (..)

import Test exposing (..)
import Expect
import Int2 exposing (..)
import Server exposing (..)
import BinaryBase64
import Model exposing (collidesWith, Tile)
import Fuzz exposing (list, int)
import Bitwise
import Main exposing (initModel)
import TileType exposing (..)


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
                collidesWith (Tile redHouseIndex (Int2 0 0) 0) (Tile 0 (Int2 0 0) 0)
                    |> Expect.equal True
        , test "Tiles next to eachother should not collide." <|
            \_ ->
                collidesWith (Tile redHouseIndex (Int2 0 0) 0) (Tile 0 (Int2 3 0) 0)
                    |> Expect.equal False
        , test "Tiles overlapping should collide." <|
            \_ ->
                collidesWith (Tile redHouseIndex (Int2 0 0) 0) (Tile redHouseIndex (Int2 2 -2) 0)
                    |> Expect.equal True
        , test "Rectangles next to eachother should not collide." <|
            \_ ->
                rectangleCollision (Int2 0 0) (Int2 3 3) (Int2 3 0) (Int2 3 3)
                    |> Expect.equal False
        , test "Point outside rectangle." <|
            \_ ->
                pointInRectangle (Int2 0 0) (Int2 3 3) (Int2 3 0)
                    |> Expect.equal False
        , test "Point inside rectangle." <|
            \_ ->
                pointInRectangle (Int2 0 0) (Int2 3 3) (Int2 2 0)
                    |> Expect.equal True
        , test "Decode int" <|
            \_ -> BinaryBase64.decode "HgAAAA==" |> Expect.equal (Ok [ 30, 0, 0, 0 ])
        , test "WriteInt" <|
            \_ -> Server.writeInt 30 |> Expect.equal [ 30, 0, 0, 0 ]
        , test "WriteInt negative value" <|
            \_ -> Server.writeInt -1 |> Expect.equal [ 255, 255, 255, 255 ]
        , test "ReadInt" <|
            \_ -> Server.readInt [ 30, 0, 0, 0 ] |> Expect.equal (Just ( [], 30 ))
        , test "ReadInt -1" <|
            \_ -> Server.readInt [ 255, 255, 255, 255 ] |> Expect.equal (Just ( [], -1 ))
        , test "ReadInt -2" <|
            \_ -> Server.readInt [ 254, 255, 255, 255 ] |> Expect.equal (Just ( [], -2 ))
        , fuzz2 int (list int) "readInt undoes writeInt" <|
            \a b ->
                let
                    input =
                        fixInt a

                    extraBytes =
                        getBytes b
                in
                    writeInt input
                        ++ extraBytes
                        |> readInt
                        |> Expect.equal (Just ( extraBytes, input ))
        , fuzz2 (list int) (list int) "readList undoes writeList" <|
            \a b ->
                let
                    input =
                        List.map fixInt a

                    extraBytes =
                        getBytes b
                in
                    writeList writeInt input
                        ++ extraBytes
                        |> readList readInt
                        |> Expect.equal (Just ( extraBytes, input ))
        , fuzz5 int int int int (list int) "readTile undoes writeTile" <|
            \a b c d e ->
                let
                    input =
                        Tile (fixInt a) (Int2 (fixInt b) (fixInt c)) (fixInt d)

                    extraBytes =
                        getBytes e
                in
                    writeTile input
                        ++ extraBytes
                        |> readTile
                        |> Expect.equal (Just ( extraBytes, input ))
        , test "Placing a house to the right of a sidewalk tile does not remove the sidewalk." <|
            \_ ->
                Main.initModel
                    |> Model.modelAddTile (Tile sidewalkIndex Int2.zero 0)
                    |> Model.modelAddTile (Tile redHouseIndex (Int2 1 0) 0)
                    |> .tiles
                    |> List.length
                    |> Expect.equal 2
        ]


{-| Make sure the integer we are using don't exceed the range of 32 bit integers.
-}
fixInt : Int -> Int
fixInt int =
    Bitwise.and 0xFFFFFFFF int


getBytes : List Int -> BinaryBase64.ByteString
getBytes ints =
    List.map (\a -> a % 256) ints
