module MassiveDecks.Util.Html exposing
    ( blankA
    , nothing
    )

{-| Utility methods for Html
-}

import Html exposing (Html)
import Html.Attributes as HtmlA


{-| A link that opens in a new tab/window by setting the target to `_blank`. This also sets `rel` to `noopener` as a
security measure.
-}
blankA : List (Html.Attribute msg) -> List (Html msg) -> Html msg
blankA attributes children =
    Html.a (attributes ++ [ HtmlA.target "_blank", HtmlA.rel "noopener" ]) children


{-| An element to use when you want to show nothing in a case where you otherwise show HTMl.
-}
nothing : Html msg
nothing =
    Html.text ""
