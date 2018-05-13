module Rectangle exposing (..)

import Point2 exposing (Point2)


type alias Rectangle a =
    { topLeft : Point2 a, size : Point2 a }
