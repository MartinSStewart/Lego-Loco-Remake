module Point2 exposing (..)


type alias Point2 number =
    { x : number, y : number }


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


{-| Multiplies one point by a scalar but with the order reversed.
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


{-| Divides one point by an integer but with the order reversed.
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


transpose : { x : a, y : a } -> { x : a, y : a }
transpose point =
    { x = point.y, y = point.x }


intToInt2 : Int -> Int -> Point2 Int
intToInt2 width int =
    Point2 (int % width) (int // width)


rectangleCollision : Point2 Int -> Point2 Int -> Point2 Int -> Point2 Int -> Bool
rectangleCollision topLeft0 size0 topLeft1 size1 =
    let
        topRight0 =
            add topLeft0 (Point2 (size0.x - 1) 0)

        bottomRight0 =
            add topLeft0 size0 |> add (Point2 -1 -1)

        topRight1 =
            add topLeft1 (Point2 (size1.x - 1) 0)

        bottomRight1 =
            add topLeft1 size1 |> add (Point2 -1 -1)
    in
        pointInRectangle topLeft0 size0 topLeft1
            || pointInRectangle topLeft0 size0 topRight1
            || pointInRectangle topLeft0 size0 bottomRight1
            || pointInRectangle topLeft1 size1 topLeft0
            || pointInRectangle topLeft1 size1 topRight0
            || pointInRectangle topLeft1 size1 bottomRight0


pointInRectangle : Point2 Int -> Point2 Int -> Point2 Int -> Bool
pointInRectangle topLeft rectangleSize point =
    let
        bottomRight =
            add topLeft rectangleSize
    in
        topLeft.x <= point.x && point.x < bottomRight.x && topLeft.y <= point.y && point.y < bottomRight.y
