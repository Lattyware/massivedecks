module MassiveDecks.Util.Html.Attributes exposing
    ( fullWidth
    , nothing
    , slot
    )

import Html exposing (Html)
import Html.Attributes as HtmlA
import Json.Encode as Json


{-| An attribute to use when you want to have nothing in a case where you otherwise show have an attribute.
-}
nothing : Html.Attribute msg
nothing =
    Json.null |> HtmlA.property ""


{-| The slot attribute.
-}
slot : String -> Html.Attribute msg
slot =
    HtmlA.attribute "slot"


{-| The full width attribute for material components.
-}
fullWidth : Html.Attribute msg
fullWidth =
    True |> Json.bool |> HtmlA.property "fullwidth"
