module MassiveDecks.Components exposing (linkButton)

{-| Reusable interface elements.
-}

import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Attributes.Aria as Aria


{-| Something that looks like a link but is actually a button suitable for handling events on click.
-}
linkButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
linkButton attrs contents =
    Html.span (HtmlA.class "link-button" :: Aria.role "button" :: HtmlA.tabindex 0 :: attrs) contents
