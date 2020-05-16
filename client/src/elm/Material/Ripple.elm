module Material.Ripple exposing (view)

import Html as HtmlA


view : List (HtmlA.Attribute msg) -> List (HtmlA.Html msg) -> HtmlA.Html msg
view =
    HtmlA.node "mwc-ripple"
