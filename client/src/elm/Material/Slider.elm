module Material.Slider exposing
    ( markers
    , max
    , min
    , onChange
    , pin
    , step
    , value
    , view
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode
import Json.Encode as Json


view : List (Html.Attribute msg) -> Html msg
view attributes =
    Html.node "mwc-slider" attributes []


step : Int -> Html.Attribute msg
step =
    Json.int >> HtmlA.property "step"


min : Int -> Html.Attribute msg
min =
    Json.int >> HtmlA.property "min"


max : Int -> Html.Attribute msg
max =
    Json.int >> HtmlA.property "max"


markers : Html.Attribute msg
markers =
    True |> Json.bool |> HtmlA.property "markers"


pin : Html.Attribute msg
pin =
    True |> Json.bool |> HtmlA.property "pin"


value : Int -> Html.Attribute msg
value =
    Json.int >> HtmlA.property "value"


onChange : (Int -> msg) -> Html.Attribute msg
onChange wrap =
    Json.Decode.at [ "target", "value" ] Json.Decode.int |> Json.Decode.map wrap |> HtmlE.on "change"
