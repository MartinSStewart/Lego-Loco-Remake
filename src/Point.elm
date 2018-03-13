module Point exposing (..)


type alias Point =
    { x : Int, y : Int }


add : Point -> Point -> Point
add point0 point1 =
    Point (point0.x + point1.x) (point0.y + point1.y)


sub : Point -> Point -> Point
sub point0 point1 =
    Point (point0.x - point1.x) (point0.y - point1.y)


mult : Point -> Int -> Point
mult point scalar =
    Point (point.x * scalar) (point.y * scalar)


setX : Int -> Point -> Point
setX x point =
    { point | x = x }


setY : Int -> Point -> Point
setY y point =
    { point | y = y }
