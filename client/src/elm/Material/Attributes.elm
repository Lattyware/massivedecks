module Material.Attributes exposing
    ( label
    , maxLength
    , minLength
    )

import Html
import Html.Attributes as HtmlA
import Json.Encode as Json


label : String -> Html.Attribute msg
label =
    HtmlA.attribute "label"


minLength : Int -> Html.Attribute msg
minLength =
    Json.int >> HtmlA.property "minLength"


maxLength : Int -> Html.Attribute msg
maxLength =
    Json.int >> HtmlA.property "maxLength"
