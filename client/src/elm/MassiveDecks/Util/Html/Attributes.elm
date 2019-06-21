module MassiveDecks.Util.Html.Attributes exposing (nothing)

import Html exposing (Html)
import Html.Attributes as HtmlA
import Json.Encode as Json


{-| An attribute to use when you want to have nothing in a case where you otherwise show have an attribute.
-}
nothing : Html.Attribute msg
nothing =
    Json.null |> HtmlA.property ""
