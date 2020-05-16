module Material.TextArea exposing (view)

import Html


view : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
view =
    Html.node "mwc-textarea"
