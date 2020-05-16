module Material.Switch exposing (view)

import Html exposing (Html)


view : List (Html.Attribute msg) -> Html msg
view attributes =
    Html.node "mwc-switch" attributes []
