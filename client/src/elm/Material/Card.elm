module Material.Card exposing (view)

import Html as HtmlA
import Html.Attributes as HtmlA


view : List (HtmlA.Attribute msg) -> List (HtmlA.Html msg) -> HtmlA.Html msg
view attributes =
    HtmlA.div (HtmlA.class "mdc-card" :: attributes)
