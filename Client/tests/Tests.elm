module Tests exposing (..)

import Test exposing (..)
import Expect
import Point2 exposing (..)
import Server exposing (..)
import BinaryBase64
import Fuzz exposing (list, int)
import Main exposing (initModel)
import TileType exposing (..)
import Helpers exposing (intMin, intMax)
import Model exposing (TileBaseData)
import Tile exposing (collidesWith, addTile)


-- Check out http://package.elm-lang.org/packages/elm-community/elm-test/latest to learn more about testing in Elm!


all : Test
all =
    describe "A Test Suite"
        [ test "Tiles right on top of eachother should collide." <|
            \_ ->
                collidesWith
                    (TileBaseData redHouseId Point2.zero 0)
                    (TileBaseData sidewalkId Point2.zero 0)
                    |> Expect.equal True
        , test "Tiles next to eachother should not collide." <|
            \_ ->
                collidesWith
                    (TileBaseData redHouseId Point2.zero 0)
                    (TileBaseData sidewalkId (Point2 3 0) 0)
                    |> Expect.equal False
        , test "Tiles overlapping should collide." <|
            \_ ->
                collidesWith
                    (TileBaseData redHouseId Point2.zero 0)
                    (TileBaseData redHouseId (Point2 2 -2) 0)
                    |> Expect.equal True
        , test "Rectangles next to eachother should not collide." <|
            \_ ->
                rectangleCollision Point2.zero (Point2 3 3) (Point2 3 0) (Point2 3 3)
                    |> Expect.equal False
        , test "Point outside rectangle." <|
            \_ ->
                pointInRectangle Point2.zero (Point2 3 3) (Point2 3 0)
                    |> Expect.equal False
        , test "Point inside rectangle." <|
            \_ ->
                pointInRectangle Point2.zero (Point2 3 3) (Point2 2 0)
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
        , fuzz2 Fuzz.bool (list (Fuzz.intRange 0 255)) "readBool undoes writeBool" <|
            \a extraBytes ->
                writeBool a
                    ++ extraBytes
                    |> readBool
                    |> Expect.equal (Just ( extraBytes, a ))
        , fuzz2 (Fuzz.intRange intMin intMax) (list (Fuzz.intRange 0 255)) "readInt undoes writeInt" <|
            \a extraBytes ->
                writeInt a
                    ++ extraBytes
                    |> readInt
                    |> Expect.equal (Just ( extraBytes, a ))
        , test "ReadFloat 0" <|
            \_ -> Server.readFloat [ 0, 0, 0, 0, 0, 0, 0, 0 ] |> Expect.equal (Just ( [], 0 ))
        , test "ReadFloat 1" <|
            \_ -> Server.readFloat [ 1, 0, 0, 0, 0, 0, 0, 0 ] |> Expect.equal (Just ( [], 1 ))
        , test "ReadFloat -1" <|
            \_ -> Server.readFloat [ 255, 255, 255, 255, 0, 0, 0, 0 ] |> Expect.equal (Just ( [], -1 ))
        , fuzz2
            (Fuzz.floatRange (Basics.toFloat intMin) (Basics.toFloat intMax))
            (list (Fuzz.intRange 0 255))
            "readFloat undoes writeFloat"
          <|
            \a extraBytes ->
                let
                    result =
                        writeFloat a
                            ++ extraBytes
                            |> readFloat
                in
                    case result of
                        Just tuple ->
                            Expect.all
                                [ Tuple.first >> Expect.equal extraBytes
                                , Tuple.second >> Expect.within (Expect.AbsoluteOrRelative 0.0001 0.0001) a
                                ]
                                tuple

                        Nothing ->
                            Expect.fail "readFloat shouldn't have failed."
        , fuzz2 (list (Fuzz.intRange intMin intMax)) (list (Fuzz.intRange 0 255)) "readList undoes writeList" <|
            \a b ->
                writeList writeInt a
                    ++ b
                    |> readList readInt
                    |> Expect.equal (Just ( b, a ))
        , fuzz5
            (List.length tiles - 1 |> Fuzz.intRange 0)
            (Fuzz.intRange intMin intMax)
            (Fuzz.intRange intMin intMax)
            (Fuzz.intRange intMin intMax)
            (list (Fuzz.intRange 0 255))
            "readTile undoes writeTile"
          <|
            \a b c d extraBytes ->
                let
                    input =
                        TileBaseData
                            (Model.TileTypeId a)
                            (Point2 b c)
                            d
                            |> Tile.initTile
                in
                    writeTile input
                        ++ extraBytes
                        |> readTile
                        |> Expect.equal (Just ( extraBytes, input ))
        , test "Placing a house to the right of a sidewalk tile does not remove the sidewalk." <|
            \_ ->
                Main.initModel
                    |> addTile (TileBaseData sidewalkId Point2.zero 0 |> Tile.initTile)
                    |> addTile (TileBaseData redHouseId (Point2 1 0) 0 |> Tile.initTile)
                    |> .tiles
                    |> List.length
                    |> Expect.equal 2
        ]
