module Weightless.Slider exposing
    ( Slot(..)
    , max
    , min
    , slot
    , step
    , thumbLabel
    )

import Html
import Weightless.Internal as Internal


type Slot
    = Before
    | After
    | ThumbLabel


slot : Slot -> Html.Attribute msg
slot s =
    let
        textSlot =
            case s of
                Before ->
                    "before"

                After ->
                    "after"

                ThumbLabel ->
                    "thumb-label"
    in
    Internal.stringAttr "slot" textSlot


step : Int -> Html.Attribute msg
step =
    Internal.numberProp "step"


min : Int -> Html.Attribute msg
min =
    Internal.numberProp "min"


max : Int -> Html.Attribute msg
max =
    Internal.numberProp "max"


thumbLabel : Bool -> Html.Attribute msg
thumbLabel =
    Internal.boolProp "thumbLabel"
