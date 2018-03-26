module Server exposing (addTile, removeTile, getRegion, update, subscription, readInt, readUInt)

import WebSocket
import Model exposing (..)
import BinaryBase64 exposing (..)
import Int2 exposing (Int2)
import Bitwise


addTile : Tile -> Cmd msg
addTile tile =
    let
        a =
            encode [ 1, 2, 3 ]
    in
        WebSocket.send serverUrl ""


removeTile : Tile -> Cmd msg
removeTile tile =
    WebSocket.send serverUrl ""


getRegion : Int2 -> Int2 -> Cmd msg
getRegion gridPos gridSize =
    WebSocket.send serverUrl ""


serverUrl : String
serverUrl =
    "ws://localhost:5523/socketservice"


update : String -> Model -> Model
update data model =
    case decode data of
        Ok a ->
            model

        --List.head a |> Maybe.andThen (\b -> updateFromCode b data model |> Just)
        Err error ->
            let
                _ =
                    Debug.log "" error
            in
                model


updateFromCode : number -> a -> b -> b
updateFromCode code data model =
    if code == 0 then
        model
    else if code == 1 then
        model
    else
        model


intMin : Int
intMin =
    -2147483648


readInt : ByteString -> Maybe Int
readInt data =
    readUInt data |> Maybe.andThen (\a -> a + intMin |> Just)


readUInt : ByteString -> Maybe Int
readUInt data =
    let
        bytes =
            List.take 4 data
    in
        if List.length bytes == 4 then
            bytes |> List.foldr (\a b -> (Bitwise.shiftLeftBy 8 a) + b) 0 |> Just
        else
            Nothing


readByte : ByteString -> Maybe Octet
readByte data =
    let
        head =
            List.head data
    in
        case head of
            Just a ->
                Just a

            Nothing ->
                Nothing


subscription : (String -> msg) -> Sub msg
subscription msg =
    WebSocket.listen serverUrl msg
