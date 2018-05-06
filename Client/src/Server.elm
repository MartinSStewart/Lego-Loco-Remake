module Server exposing (..)

import WebSocket
import Model exposing (..)
import BinaryBase64 exposing (..)
import Point2 exposing (Point2)
import Bitwise
import Helpers
import Monocle.Lens as Lens
import Lenses
import Config


version : number
version =
    0


send : List Action -> Cmd msg
send actions =
    -- let
    --     _ =
    --         Debug.log "Sending" actions
    -- in
    case actions of
        head :: rest ->
            writeInt version
                ++ writeList writeAction actions
                |> encode
                |> WebSocket.send serverUrl

        _ ->
            Cmd.none


type Action
    = AddTile Tile
    | RemoveTile Tile
    | GetRegion (Point2 Int) (Point2 Int)


type Response
    = AddedTile Tile
    | RemovedTile Tile
    | GotRegion (Point2 Int) (Point2 Int) (List Tile)


writeAction : Action -> ByteString
writeAction action =
    case action of
        AddTile tile ->
            writeInt Config.addTile ++ writeTile tile

        RemoveTile tile ->
            writeInt Config.removeTile ++ writeTile tile

        GetRegion topLeft gridSize ->
            writeInt Config.getRegion ++ writePoint2 topLeft ++ writePoint2 gridSize


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
                                Helpers.modelAddTile tile model

                            RemovedTile tile ->
                                model |> Lens.modify Lenses.tiles (List.filter ((/=) tile))

                            GotRegion topLeft size tiles ->
                                let
                                    newTiles =
                                        model.tiles
                                            |> List.filter (\a -> Point2.pointInRectangle topLeft size a.position |> not)
                                            |> (++) tiles
                                in
                                    { model | tiles = newTiles }
                    )
                    model

        Err error ->
            let
                _ =
                    Debug.log "Invalid base64" error
            in
                model


read : ByteString -> Maybe (List Response)
read data =
    readInt data
        |> Maybe.andThen
            (\( bytesLeft, version ) ->
                readList readResponse bytesLeft
                    |> Maybe.andThen
                        (\( lastBytes, responses ) ->
                            if List.length lastBytes == 0 then
                                Just responses
                            else
                                let
                                    _ =
                                        Debug.log "Decode error" ("Message too long " ++ toString lastBytes)
                                in
                                    Nothing
                        )
            )


readResponse : ByteString -> Maybe ( ByteString, Response )
readResponse data =
    let
        a bytes responseCode =
            if responseCode == Config.addedTile then
                readTile bytes |> Maybe.andThen (\( bytesLeft, tile ) -> Just ( bytesLeft, AddedTile tile ))
            else if responseCode == Config.removedTile then
                readTile bytes |> Maybe.andThen (\( bytesLeft, tile ) -> Just ( bytesLeft, RemovedTile tile ))
            else if responseCode == Config.gotRegion then
                readPoint2 bytes
                    |> Maybe.andThen
                        (\( bytesLeft, topLeft ) ->
                            readPoint2 bytesLeft
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

        _ =
            bytes |> List.all inIntRange |> assert "Value is outside integer range."
    in
        if List.length bytes == 4 then
            bytes
                |> List.foldr (\a b -> b |> Bitwise.shiftLeftBy 8 |> Bitwise.or a) 0
                |> (,) remainingBytes
                |> Just
        else
            Nothing


readBool : ByteString -> Maybe ( ByteString, Bool )
readBool data =
    case data of
        a :: rest ->
            if a == 0 then
                Just ( rest, False )
            else if a == 1 then
                Just ( rest, True )
            else
                Nothing

        _ ->
            Nothing


readPoint2 : ByteString -> Maybe ( ByteString, Point2 Int )
readPoint2 data =
    readInt data
        |> Maybe.andThen
            (\( bytesLeft, x ) ->
                readInt bytesLeft
                    |> Maybe.andThen (\( bytesLeft, y ) -> Just ( bytesLeft, Point2 x y ))
            )


readTile : ByteString -> Maybe ( ByteString, Tile )
readTile data =
    readInt data
        |> Maybe.andThen
            (\( bytesLeft, tileId ) ->
                readPoint2 bytesLeft
                    |> Maybe.andThen
                        (\( bytesLeft, gridPos ) ->
                            readInt bytesLeft
                                |> Maybe.andThen
                                    (\( bytesLeft, rotation ) ->
                                        readTileData bytesLeft
                                            |> Maybe.andThen
                                                (\( bytesLeft, tileData ) ->
                                                    Just ( bytesLeft, Tile (Model.TileTypeId tileId) gridPos rotation tileData )
                                                )
                                    )
                        )
            )


readTileData : ByteString -> Maybe ( ByteString, TileData )
readTileData data =
    readInt data
        |> Maybe.andThen
            (\( bytesLeft, tileDataType ) ->
                if tileDataType == 0 then
                    Just ( bytesLeft, TileBasic )
                else if tileDataType == 1 then
                    Just ( bytesLeft, TileRail )
                else if tileDataType == 2 then
                    readBool bytesLeft
                        |> Maybe.andThen
                            (\( bytesLeft, bool ) ->
                                Just ( bytesLeft, TileRailFork bool )
                            )
                else if tileDataType == 3 then
                    readBool bytesLeft
                        |> Maybe.andThen
                            (\( bytesLeft, bool ) ->
                                Just ( bytesLeft, TileDepot bool )
                            )
                else
                    Nothing
            )


writeByte : Int -> ByteString
writeByte byte =
    let
        _ =
            inByteRange byte |> assert "Value is outside byte range"
    in
        [ Bitwise.and byte 0xFF ]


writeBool : Bool -> ByteString
writeBool bool =
    if bool then
        writeByte 1
    else
        writeByte 0


writeInt : Int -> ByteString
writeInt int =
    let
        _ =
            inIntRange int |> assert "Value is outside integer range."
    in
        [ int |> Bitwise.and 0xFF
        , int |> Bitwise.and 0xFF00 |> Bitwise.shiftRightZfBy 8
        , int |> Bitwise.and 0x00FF0000 |> Bitwise.shiftRightZfBy 16
        , int |> Bitwise.and 0xFF000000 |> Bitwise.shiftRightZfBy 24
        ]


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


writePoint2 : Point2 Int -> ByteString
writePoint2 point =
    writeInt point.x ++ writeInt point.y


writeTile : Tile -> ByteString
writeTile tile =
    let
        (Model.TileTypeId id) =
            tile.tileId
    in
        writeInt id
            ++ writePoint2 tile.position
            ++ writeInt tile.rotationIndex
            ++ writeTileData tile.data


writeTileData : TileData -> ByteString
writeTileData tileData =
    case tileData of
        TileBasic ->
            writeInt 0

        TileRail ->
            writeInt 1

        TileRailFork isOn ->
            writeInt 2 ++ writeBool isOn

        TileDepot occupied ->
            writeInt 3 ++ writeBool occupied


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
