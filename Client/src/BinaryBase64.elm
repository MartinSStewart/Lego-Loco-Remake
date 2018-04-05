module BinaryBase64
    exposing
        ( ByteString
        , Octet
        , decode
        , encode
        )

{-| Library for encoding Binary to Base64 and vice-versa,


# Definition


# Data Types

@docs Octet, ByteString


# Functions

@docs encode, decode

-}

import Array exposing (..)
import Bitwise exposing (..)
import Char exposing (fromCode, toCode)
import Debug exposing (..)
import List.Extra
import Maybe exposing (withDefault)
import String exposing (fromList, toList)


infixl 6 |||


infixl 6 &&&


infixl 7 <<<


infixl 7 >>>


{-| an 8-bit word masquerading as an Int - we don't have an elm Byte type yet
-}
type alias Octet =
    Int


{-| a ByteString - a list of Octets
-}
type alias ByteString =
    List Octet


(<<<) =
    flip Bitwise.shiftLeftBy


(>>>) =
    flip Bitwise.shiftRightBy


(&&&) =
    Bitwise.and


(|||) =
    Bitwise.or


encodeArray : Array Char
encodeArray =
    Array.fromList
        [ 'A'
        , 'B'
        , 'C'
        , 'D'
        , 'E'
        , 'F'
        , 'G'
        , 'H'
        , 'I'
        , 'J'
        , 'K'
        , 'L'
        , 'M'
        , 'N'
        , 'O'
        , 'P'
        , 'Q'
        , 'R'
        , 'S'
        , 'T'
        , 'U'
        , 'V'
        , 'W'
        , 'X'
        , 'Y'
        , 'Z'
        , 'a'
        , 'b'
        , 'c'
        , 'd'
        , 'e'
        , 'f'
        , 'g'
        , 'h'
        , 'i'
        , 'j'
        , 'k'
        , 'l'
        , 'm'
        , 'n'
        , 'o'
        , 'p'
        , 'q'
        , 'r'
        , 's'
        , 't'
        , 'u'
        , 'v'
        , 'w'
        , 'x'
        , 'y'
        , 'z'
        , '0'
        , '1'
        , '2'
        , '3'
        , '4'
        , '5'
        , '6'
        , '7'
        , '8'
        , '9'
        , '+'
        , '/'
        ]


int4_char3 : List Int -> List Char
int4_char3 is =
    let
        groupsOfFour values =
            let
                grouper elem acc =
                    case acc of
                        [] ->
                            [ [ elem ] ]

                        x :: xs ->
                            if List.length x == 4 then
                                [ elem ] :: acc
                            else
                                (x ++ [ elem ]) :: xs
            in
                List.reverse <| List.foldl grouper [] values
    in
        is
            |> groupsOfFour
            |> List.map
                (\subgroup ->
                    case subgroup of
                        a :: b :: c :: d :: t ->
                            let
                                n =
                                    (a <<< 18) ||| (b <<< 12) ||| (c <<< 6) ||| d
                            in
                                fromCode (n >>> 16 &&& 0xFF)
                                    :: fromCode (n >>> 8 &&& 0xFF)
                                    :: fromCode (n &&& 0xFF)
                                    :: []

                        [ a, b, c ] ->
                            let
                                n =
                                    (a <<< 18) ||| (b <<< 12) ||| (c <<< 6)
                            in
                                [ fromCode (n >>> 16 &&& 0xFF)
                                , fromCode (n >>> 8 &&& 0xFF)
                                ]

                        [ a, b ] ->
                            let
                                n =
                                    (a <<< 18) ||| (b <<< 12)
                            in
                                [ fromCode (n >>> 16 &&& 0xFF) ]

                        [ _ ] ->
                            log "int4_char3: impossible number of Ints." []

                        [] ->
                            []
                )
            |> List.concat


char3_int4 : List Char -> List Int
char3_int4 cs =
    char3_int4_fold cs []


char3_int4_fold : List Char -> List Int -> List Int
char3_int4_fold cs acc =
    case cs of
        a :: b :: c :: t ->
            let
                n =
                    (toCode a <<< 16) ||| (toCode b <<< 8) ||| toCode c

                --    (toCode a `shiftLeft` 16) `or` (toCode b `shiftLeft` 8) `or` (toCode c)
            in
                char3_int4_fold t (acc ++ [ n >>> 18 &&& 0x3F, n >>> 12 &&& 0x3F, n >>> 6 &&& 0x3F, n &&& 0x3F ])

        --   (n `shiftRight` 18 `and` 0x3F) :: (n `shiftRight` 12 `and` 0x3F) :: (n `shiftRight` 6 `and` 0x3F) :: (n `and` 0x3F) :: char3_int4 t
        [ a, b ] ->
            let
                n =
                    (toCode a <<< 16) ||| (toCode b <<< 8)

                --   (toCode a `shiftLeft` 16) `or` (toCode b `shiftLeft` 8)
            in
                acc
                    ++ [ n >>> 18 &&& 0x3F
                       , n >>> 12 &&& 0x3F
                       , n >>> 6 &&& 0x3F
                       ]

        {-
           [ (n `shiftRight` 18 `and` 0x3F)
           , (n `shiftRight` 12 `and` 0x3F)
           , (n `shiftRight` 6 `and` 0x3F)
           ]
        -}
        [ a ] ->
            let
                n =
                    toCode a <<< 16

                --   (toCode a `shiftLeft` 16)
            in
                acc
                    ++ [ n >>> 18 &&& 0x3F
                       , n >>> 12 &&& 0x3F
                       ]

        {-
           [ (n `shiftRight` 18 `and` 0x3F)
           , (n `shiftRight` 12 `and` 0x3F)
           ]
        -}
        [] ->
            acc



-- Retrieve base64 char, given an array index integer in the range [0..63]


enc1 : Int -> Char
enc1 i =
    Array.get i encodeArray
        |> withDefault '?'



-- Pad a base64 code to a multiple of 4 characters, using the special
-- '=' character.


quadruplets : List Char -> List Char
quadruplets cs =
    quadruplets_fold cs []


quadruplets_fold : List Char -> List Char -> List Char
quadruplets_fold cs acc =
    case cs of
        a :: b :: c :: d :: t ->
            quadruplets_fold t (acc ++ [ a, b, c, d ])

        [ a, b, c ] ->
            acc ++ [ a, b, c, '=' ]

        -- 16bit tail unit
        [ a, b ] ->
            acc ++ [ a, b, '=', '=' ]

        -- 8bit tail unit
        [ _ ] ->
            log "quadruplets: impossible number of characters." []

        [] ->
            acc



-- 24bit tail unit
-- worker that encodes and then pads to a quadruplet multiple


enc : List Int -> List Char
enc =
    List.map enc1
        >> quadruplets



-- decode worker


dcd : List Char -> List Int
dcd cs =
    cs
        |> List.Extra.takeWhile (\a -> a /= '=')
        |> List.map
            (\h ->
                if h <= 'Z' && h >= 'A' then
                    toCode h - toCode 'A'
                else if h >= '0' && h <= '9' then
                    toCode h - toCode '0' + 52
                else if h >= 'a' && h <= 'z' then
                    toCode h - toCode 'a' + 26
                else if h == '+' then
                    62
                else if h == '/' then
                    63
                else
                    -- This case can't happen since we only call this function if isBase64 is true.
                    0
            )


isBase64Char : Char -> Bool
isBase64Char c =
    (List.member c <| Array.toList encodeArray) || (c == '=')


isBase64 : String -> Bool
isBase64 =
    String.all isBase64Char



-- top level decoding


decodeString : String -> ByteString
decodeString =
    -- log "decode buffer" >>
    String.toList
        >> dcd
        >> int4_char3
        >> List.map toCode



-- Exported functions.


{-| encode a ByteString as Base64
-}
encode : ByteString -> String
encode =
    -- log "encode buffer" >>
    List.map fromCode
        >> char3_int4
        >> enc
        >> String.fromList


{-| decode a Base64 String
-}
decode : String -> Result String ByteString
decode s =
    if isBase64 s then
        -- Ok <| log "decoded buffer" (decodeString s)
        Ok (decodeString s)
    else
        Err "invalid Base64 string"
