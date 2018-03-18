module Int2 exposing (..)


type alias Int2 =
    { x : Int, y : Int }


type alias Float2 =
    { x : Float, y : Float }


add :
    { x : number, y : number }
    -> { x : number, y : number }
    -> { x : number, y : number }
add point0 point1 =
    { x = point0.x + point1.x, y = point0.y + point1.y }


sub :
    { x : number, y : number }
    -> { x : number, y : number }
    -> { x : number, y : number }
sub point0 point1 =
    { x = point0.x - point1.x, y = point0.y - point1.y }


multScalar : { x : number, y : number } -> number -> { x : number, y : number }
multScalar point scalar =
    { x = point.x * scalar, y = point.y * scalar }


mult : { x : number, y : number } -> { x : number, y : number } -> { x : number, y : number }
mult point0 point1 =
    { x = point0.x * point1.x, y = point0.y * point1.y }


div : Int -> Int2 -> Int2
div divisor point =
    { x = point.x // divisor, y = point.y // divisor }


setX : number -> { c | x : number } -> { c | x : number }
setX x point =
    { point | x = x }


setY : number -> { c | y : number } -> { c | y : number }
setY y point =
    { point | y = y }


negate :
    { x : number, y : number }
    -> { x : number, y : number }
negate point =
    { x = -point.x, y = -point.y }


rectangleCollision : Int2 -> Int2 -> Int2 -> Int2 -> Bool
rectangleCollision topLeft0 size0 topLeft1 size1 =
    let
        topRight0 =
            add topLeft0 (Int2 (size1.x - 1) 0)

        bottomRight0 =
            add topLeft0 size0 |> add (Int2 -1 -1)

        topRight1 =
            add topLeft1 (Int2 (size1.x - 1) 0)

        bottomRight1 =
            add topLeft1 size1 |> add (Int2 -1 -1)
    in
        pointInsideRectangle topLeft0 size0 topLeft1
            || pointInsideRectangle topLeft0 size0 topRight1
            || pointInsideRectangle topLeft0 size0 bottomRight1
            || pointInsideRectangle topLeft1 size1 topLeft0
            || pointInsideRectangle topLeft1 size1 topRight0
            || pointInsideRectangle topLeft1 size1 bottomRight0


pointInsideRectangle : Int2 -> Int2 -> Int2 -> Bool
pointInsideRectangle topLeft rectangleSize point =
    let
        bottomRight =
            add topLeft rectangleSize
    in
        topLeft.x <= point.x && point.x < bottomRight.x && topLeft.y <= point.y && point.y < bottomRight.y
