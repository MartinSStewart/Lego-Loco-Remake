module ServerTests exposing (..)

import BinaryBase64
import Expect
import Fuzz exposing (int, list)
import Helpers exposing (intMax, intMin)
import Server exposing (..)
import Test exposing (..)
import TestHelper


all : Test
all =
    describe "Server tests"
        [ test "Decode int" <|
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
        , fuzz2
            TestHelper.fuzzTile
            (list (Fuzz.intRange 0 255))
            "readTile undoes writeTile"
          <|
            \fuzzTile extraBytes ->
                let
                    input =
                        TestHelper.fuzzTileToTile fuzzTile
                in
                    writeTile input
                        ++ extraBytes
                        |> readTile
                        |> Expect.equal (Just ( extraBytes, input ))
        ]
