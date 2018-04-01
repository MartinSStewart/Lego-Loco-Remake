module Server exposing (send, update, subscription, readInt, writeInt, Action(..))

import WebSocket
import Model exposing (..)
import BinaryBase64 exposing (..)
import Int2 exposing (Int2)
import Bitwise


version : number
version =
    0


send : List Action -> Cmd msg
send actions =
    writeInt version
        ++ writeList writeAction actions
        |> encode
        |> WebSocket.send serverUrl


type Action
    = AddTile Tile
    | RemoveTile Tile
    | GetRegion Int2 Int2


type Response
    = AddedTile Tile
    | RemovedTile Tile
    | GotRegion Int2 Int2 (List Tile)


writeAction : Action -> ByteString
writeAction action =
    case action of
        AddTile tile ->
            writeInt 0 ++ writeTile tile

        RemoveTile tile ->
            writeInt 1 ++ writeTile tile

        GetRegion topLeft gridSize ->
            writeInt 2 ++ writeInt2 topLeft ++ writeInt2 gridSize


serverUrl : String
serverUrl =
    "ws://localhost:5523/socketservice"


update : String -> Model -> Model
update data model =
    case decode data of
        Ok a ->
            read a
                |> Maybe.withDefault []
                |> List.foldl
                    (\response model ->
                        case response of
                            AddedTile tile ->
                                model

                            RemovedTile tile ->
                                model

                            GotRegion topLeft size tiles ->
                                model
                     --List.foldl modelAddTile model
                    )
                    model

        Err error ->
            let
                _ =
                    Debug.log "" error
            in
                model


read : ByteString -> Maybe (List Response)
read data =
    readInt data
        |> Maybe.andThen
            (\( bytesLeft, version ) ->
                readList readResponse bytesLeft
                    |> Maybe.andThen
                        (\( bytesLeft, responses ) ->
                            if List.length bytesLeft == 0 then
                                Just responses
                            else
                                Nothing
                        )
            )


readResponse : ByteString -> Maybe ( ByteString, Response )
readResponse data =
    let
        a bytes responseCode =
            if responseCode == 0 then
                Nothing
            else if responseCode == 1 then
                Nothing
            else if responseCode == 2 then
                readInt2 bytes
                    |> Maybe.andThen
                        (\( bytesLeft, topLeft ) ->
                            readInt2 bytesLeft
                                |> Maybe.andThen
                                    (\( bytesLeft, size ) ->
                                        readList readTile bytesLeft
                                            |> Maybe.andThen
                                                (\( bytesLeft, tiles ) ->
                                                    Just ( bytesLeft, GotRegion topLeft size tiles )
                                                )
                                    )
                        )
            else
                Nothing
    in
        readInt data |> Maybe.andThen (\( bytesLeft, responseCode ) -> a bytesLeft responseCode)


readInt : ByteString -> Maybe ( ByteString, Int )
readInt data =
    let
        bytes =
            List.take 4 data

        remainingBytes =
            List.drop 4 data
    in
        if List.length bytes == 4 then
            bytes
                |> List.foldr (\a b -> b |> Bitwise.shiftLeftBy 8 |> Bitwise.or a) 0
                |> (,) remainingBytes
                |> Just
        else
            Nothing


readInt2 : ByteString -> Maybe ( ByteString, Int2 )
readInt2 data =
    readInt data
        |> Maybe.andThen
            (\( bytesLeft, x ) ->
                readInt bytesLeft
                    |> Maybe.andThen (\( bytesLeft, y ) -> Just ( bytesLeft, Int2 x y ))
            )


readTile : ByteString -> Maybe ( ByteString, Tile )
readTile data =
    readInt data
        |> Maybe.andThen
            (\( bytesLeft, tileId ) ->
                readInt2 bytesLeft
                    |> Maybe.andThen
                        (\( bytesLeft, gridPos ) ->
                            readInt bytesLeft
                                |> Maybe.andThen
                                    (\( bytesLeft, rotation ) ->
                                        Just ( bytesLeft, Tile tileId gridPos rotation )
                                    )
                        )
            )


writeByte : Int -> ByteString
writeByte byte =
    let
        _ =
            inByteRange byte |> assert "Value is outside byte range"
    in
        [ Bitwise.and byte 0xFF ]


writeInt : Int -> ByteString
writeInt int =
    let
        _ =
            inIntRange int |> assert "Value is outside integer range."

        byte0 =
            int |> Bitwise.and 0xFF

        byte1 =
            int |> Bitwise.and 0xFF00 |> Bitwise.shiftRightZfBy 8

        byte2 =
            int |> Bitwise.and 0x00FF0000 |> Bitwise.shiftRightZfBy 16

        byte3 =
            int |> Bitwise.and 0xFF000000 |> Bitwise.shiftRightZfBy 24
    in
        [ byte0, byte1, byte2, byte3 ]


writeList : (a -> ByteString) -> List a -> ByteString
writeList writer list =
    let
        count =
            List.length list |> writeInt

        listBytes =
            list |> List.foldl (\a b -> b ++ (writer a)) []
    in
        count ++ listBytes


readList : (ByteString -> Maybe ( ByteString, a )) -> ByteString -> Maybe ( ByteString, List a )
readList reader data =
    let
        readSubList reader data items count =
            if count == 0 then
                Just ( data, items )
            else
                reader data
                    |> Maybe.andThen (\( remainingData, item ) -> readSubList reader remainingData (item :: items) (count - 1))
    in
        readInt data
            |> Maybe.andThen (\( bytesLeft, count ) -> readSubList reader bytesLeft [] count)
            |> Maybe.andThen (\( bytesLeft, items ) -> Just ( bytesLeft, List.reverse items ))


writeInt2 : Int2 -> ByteString
writeInt2 int2 =
    writeInt int2.x ++ writeInt int2.y


writeTile : Tile -> ByteString
writeTile tile =
    writeInt tile.tileId ++ writeInt2 tile.position ++ writeInt tile.rotationIndex


inIntRange : Int -> Bool
inIntRange int =
    int <= 2147483647 || int >= -2147483648


inByteRange : Int -> Bool
inByteRange int =
    int <= 255 || int >= 0


assert : String -> Bool -> Bool
assert message assertion =
    if assertion then
        assertion
    else
        Debug.crash message assertion


readByte : ByteString -> Maybe ( ByteString, Octet )
readByte data =
    case List.head data of
        Just a ->
            Just ( List.drop 1 data, a )

        Nothing ->
            Nothing


subscription : (String -> msg) -> Sub msg
subscription msg =
    WebSocket.listen serverUrl msg
