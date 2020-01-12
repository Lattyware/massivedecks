module Weightless.ProgressBar exposing
    ( determinate
    , indeterminate
    )

import Html exposing (Html)
import Weightless.Internal as Internal


determinate : Float -> List (Html.Attribute msg) -> Html msg
determinate completion attrs =
    progressBar ([ mode Determinate, value completion ] ++ attrs) []


indeterminate : List (Html.Attribute msg) -> Html msg
indeterminate attrs =
    progressBar attrs []



{- Private -}


type ProgressMode
    = Indeterminate
    | Determinate


progressBar : List (Html.Attribute msg) -> List (Html msg) -> Html msg
progressBar =
    Html.node "wl-progress-bar"


mode : ProgressMode -> Html.Attribute msg
mode =
    progressModeName >> Internal.stringProp "mode"


value : Float -> Html.Attribute msg
value =
    Internal.floatProp "value"


progressModeName : ProgressMode -> String
progressModeName progressMode =
    case progressMode of
        Indeterminate ->
            "indeterminate"

        Determinate ->
            "determinate"
