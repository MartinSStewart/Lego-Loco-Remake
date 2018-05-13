module Rectangle exposing (..)

import Point2 exposing (Point2, inRectangle)


type alias Rectangle a =
    { topLeft : Point2 a, size : Point2 a }


overlap : Point2 Int -> Point2 Int -> Point2 Int -> Point2 Int -> Bool
overlap topLeft0 size0 topLeft1 size1 =
    let
        topRight0 =
            Point2.add topLeft0 (Point2 (size0.x - 1) 0)

        bottomRight0 =
            Point2.add topLeft0 size0 |> Point2.add (Point2 -1 -1)

        topRight1 =
            Point2.add topLeft1 (Point2 (size1.x - 1) 0)

        bottomRight1 =
            Point2.add topLeft1 size1 |> Point2.add (Point2 -1 -1)
    in
        inRectangle topLeft0 size0 topLeft1
            || inRectangle topLeft0 size0 topRight1
            || inRectangle topLeft0 size0 bottomRight1
            || inRectangle topLeft1 size1 topLeft0
            || inRectangle topLeft1 size1 topRight0
            || inRectangle topLeft1 size1 bottomRight0
