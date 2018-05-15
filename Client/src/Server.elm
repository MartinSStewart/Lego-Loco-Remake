module Server exposing (..)

import BinaryBase64 exposing (..)
import Bitwise
import Config
import Helpers
import Lenses
import Model exposing (..)
import Monocle.Lens as Lens
import Point2 exposing (Point2)
import WebSocket
import Grid
import Set


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
    | RemoveTile TileBaseData
    | ClickTile TileBaseData
    | GetRegion (Point2 Int)


type Response
    = AddedTile Tile
    | RemovedTile TileBaseData
    | ClickedTile TileBaseData
    | GotRegion (Point2 Int) (List Tile)


writeAction : Action -> ByteString
writeAction action =
    case action of
        AddTile tile ->
            writeInt Config.addTile ++ writeTile tile

        RemoveTile baseData ->
            writeInt Config.removeTile ++ writeTileBaseData baseData

        ClickTile baseData ->
            writeInt Config.clickTile ++ writeTileBaseData baseData

        GetRegion superGridPos ->
            writeInt Config.getRegion ++ writePoint2 superGridPos


serverUrl : String
serverUrl =
    --"ws://40.114.70.41:5523/socketservice"
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
                                model |> Lens.modify Lenses.tiles (Grid.addTile tile)

                            RemovedTile baseData ->
                                model |> Lens.modify Lenses.tiles (Grid.removeTile baseData)

                            ClickedTile baseData ->
                                model |> Lens.modify Lenses.tiles (Grid.clickTile baseData)

                            GotRegion superGridPos tiles ->
                                model
                                    |> Lens.modify
                                        Lenses.tiles
                                        (Grid.loadTiles superGridPos tiles)
                                    |> Lens.modify
                                        Lenses.pendingGetRegions
                                        (Set.remove (Point2.toTuple superGridPos))
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
                readTileBaseData bytes
                    |> Maybe.andThen (\( bytesLeft, baseData ) -> Just ( bytesLeft, RemovedTile baseData ))
            else if responseCode == Config.clickedTile then
                readTileBaseData bytes
                    |> Maybe.andThen (\( bytesLeft, baseData ) -> Just ( bytesLeft, ClickedTile baseData ))
            else if responseCode == Config.gotRegion then
                readPoint2 bytes
                    |> Maybe.andThen
                        (\( bytesLeft, superGridPos ) ->
                            readList readTile bytesLeft
                                |> Maybe.andThen
                                    (\( bytesLeft, tiles ) ->
                                        Just ( bytesLeft, GotRegion superGridPos tiles )
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


readFloat : ByteString -> Maybe ( ByteString, Float )
readFloat data =
    readInt data
        |> Maybe.andThen
            (\( bytesLeft, integerPart ) ->
                readInt bytesLeft
                    |> Maybe.andThen
                        (\( bytesLeft, fractionalPart ) ->
                            Just ( bytesLeft, toFloat integerPart + (toFloat fractionalPart) / (toFloat Helpers.intMax) )
                        )
            )


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
    readTileBaseData data
        |> Maybe.andThen
            (\( bytesLeft, tileBaseData ) ->
                readTileData bytesLeft
                    |> Maybe.andThen
                        (\( bytesLeft, tileData ) ->
                            Just ( bytesLeft, Tile tileBaseData tileData )
                        )
            )


readTileBaseData : ByteString -> Maybe ( ByteString, TileBaseData )
readTileBaseData data =
    readInt data
        |> Maybe.andThen
            (\( bytesLeft, tileId ) ->
                readPoint2 bytesLeft
                    |> Maybe.andThen
                        (\( bytesLeft, gridPos ) ->
                            readInt bytesLeft
                                |> Maybe.andThen
                                    (\( bytesLeft, rotation ) ->
                                        Just ( bytesLeft, TileBaseData (Model.TileTypeId tileId) gridPos rotation )
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
                    readList readTrain bytesLeft
                        |> Maybe.andThen
                            (\( bytesLeft, trains ) ->
                                Just ( bytesLeft, TileRail trains )
                            )
                else if tileDataType == 2 then
                    readList readTrain bytesLeft
                        |> Maybe.andThen
                            (\( bytesLeft, trains ) ->
                                readBool bytesLeft
                                    |> Maybe.andThen
                                        (\( bytesLeft, bool ) ->
                                            Just ( bytesLeft, TileRailFork trains bool )
                                        )
                            )
                else if tileDataType == 3 then
                    readList readTrain bytesLeft
                        |> Maybe.andThen
                            (\( bytesLeft, trains ) ->
                                readBool bytesLeft
                                    |> Maybe.andThen
                                        (\( bytesLeft, bool ) ->
                                            Just ( bytesLeft, TileDepot trains bool )
                                        )
                            )
                else
                    Nothing
            )


readTrain : ByteString -> Maybe ( ByteString, Train )
readTrain data =
    readFloat data
        |> Maybe.andThen
            (\( bytesLeft, t ) ->
                readFloat bytesLeft
                    |> Maybe.andThen
                        (\( bytesLeft, speed ) ->
                            Just ( bytesLeft, Train t speed )
                        )
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


writeFloat : Float -> ByteString
writeFloat float =
    let
        integerPart =
            floor float

        fractionalPart =
            (float - toFloat integerPart) * toFloat Helpers.intMax |> floor
    in
        writeInt integerPart ++ writeInt fractionalPart


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
                case reader data of
                    Just ( remainingData, item ) ->
                        readSubList reader remainingData (item :: items) (count - 1)

                    Nothing ->
                        Nothing
    in
        readInt data
            |> Maybe.andThen (\( bytesLeft, count ) -> readSubList reader bytesLeft [] count)
            |> Maybe.andThen (\( bytesLeft, items ) -> Just ( bytesLeft, List.reverse items ))


writePoint2 : Point2 Int -> ByteString
writePoint2 point =
    writeInt point.x ++ writeInt point.y


writeTile : Tile -> ByteString
writeTile tile =
    writeTileBaseData tile.baseData ++ writeTileData tile.data


writeTileBaseData : TileBaseData -> ByteString
writeTileBaseData baseData =
    let
        (Model.TileTypeId id) =
            baseData.tileId
    in
        writeInt id
            ++ writePoint2 baseData.position
            ++ writeInt baseData.rotationIndex


writeTileData : TileData -> ByteString
writeTileData tileData =
    case tileData of
        TileBasic ->
            writeInt 0

        TileRail trains ->
            writeInt 1 ++ writeList writeTrain trains

        TileRailFork trains isOn ->
            writeInt 2 ++ writeList writeTrain trains ++ writeBool isOn

        TileDepot trains occupied ->
            writeInt 3 ++ writeList writeTrain trains ++ writeBool occupied


writeTrain : Train -> ByteString
writeTrain train =
    writeFloat train.t ++ writeFloat train.speed


inIntRange : Int -> Bool
inIntRange int =
    int <= Helpers.intMax || int >= Helpers.intMin


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
