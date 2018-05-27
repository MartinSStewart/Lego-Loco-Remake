module Point2 exposing (..)


type alias Point2 number =
    { x : number
    , y : number
    }


add : Point2 number -> Point2 number -> Point2 number
add point0 point1 =
    { x = point0.x + point1.x, y = point0.y + point1.y }


sub : Point2 number -> Point2 number -> Point2 number
sub point0 point1 =
    { x = point0.x - point1.x, y = point0.y - point1.y }


rsub : Point2 number -> Point2 number -> Point2 number
rsub point1 point0 =
    { x = point0.x - point1.x, y = point0.y - point1.y }


multScalar : Point2 number -> number -> Point2 number
multScalar point scalar =
    { x = point.x * scalar, y = point.y * scalar }


{-| Multiplies one point by a scalar but with the parameter order reversed.
-}
rmultScalar : number -> Point2 number -> Point2 number
rmultScalar scalar point =
    { x = point.x * scalar, y = point.y * scalar }


mult : Point2 number -> Point2 number -> Point2 number
mult point0 point1 =
    { x = point0.x * point1.x, y = point0.y * point1.y }


div : Point2 Int -> Int -> Point2 Int
div point divisor =
    { x = point.x // divisor, y = point.y // divisor }


{-| Divides one point by an integer but with the parameter order reversed.
-}
rdiv : Int -> Point2 Int -> Point2 Int
rdiv divisor point =
    { x = point.x // divisor, y = point.y // divisor }


negate : Point2 number -> Point2 number
negate point =
    { x = -point.x, y = -point.y }


zero : Point2 number
zero =
    { x = 0, y = 0 }


one : Point2 number
one =
    { x = 1, y = 1 }


min : Point2 number -> Point2 number -> Point2 number
min point0 point1 =
    --Due to a compiler bug, we need to add 0. Otherwise we can't use number types in Basics.min.
    { x = Basics.min (point0.x + 0) point1.x, y = Basics.min point0.y point1.y }


max : Point2 number -> Point2 number -> Point2 number
max point0 point1 =
    --Due to a compiler bug, we need to add 0. Otherwise we can't use number types in Basics.min.
    { x = Basics.max (point0.x + 0) point1.x, y = Basics.max point0.y point1.y }


floor : Point2 Float -> Point2 Int
floor float2 =
    Point2 (Basics.floor float2.x) (Basics.floor float2.y)


toFloat : Point2 Int -> Point2 Float
toFloat int2 =
    Point2 (Basics.toFloat int2.x) (Basics.toFloat int2.y)


toTuple : Point2 number -> ( number, number )
toTuple point =
    ( point.x, point.y )


fromTuple : ( number, number ) -> Point2 number
fromTuple ( x, y ) =
    Point2 x y


transpose : { x : a, y : a } -> { x : a, y : a }
transpose point =
    { x = point.y, y = point.x }


intToInt2 : Int -> Int -> Point2 Int
intToInt2 width int =
    Point2 (int % width) (int // width)


area : Point2 number -> number
area point =
    point.x * point.y


length : Point2 Float -> Float
length point =
    point.x * point.x + point.y * point.y |> sqrt


inRectangle : Point2 Int -> Point2 Int -> Point2 Int -> Bool
inRectangle topLeft rectangleSize point =
    let
        assertSize =
            if rectangleSize.x < 0 || rectangleSize.y < 0 then
                Debug.crash "Negative size not allowed."
            else
                ""

        bottomRight =
            add topLeft rectangleSize
    in
        topLeft.x <= point.x && point.x < bottomRight.x && topLeft.y <= point.y && point.y < bottomRight.y


rotateBy90 : Int -> Point2 number -> Point2 number
rotateBy90 rotateBy point =
    if rotateBy % 4 == 1 then
        Point2 point.y -point.x
    else if rotateBy % 4 == 2 then
        Point2 -point.x -point.y
    else if rotateBy % 4 == 3 then
        Point2 -point.y point.x
    else
        point
