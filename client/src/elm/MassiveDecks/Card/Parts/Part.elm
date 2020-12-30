module MassiveDecks.Card.Parts.Part exposing
    ( Style(..)
    , Transform(..)
    , styledElement
    , transformAttrs
    , transformClass
    , transformedStyledElement
    )

import Html
import Html.Attributes as HtmlA
import MassiveDecks.Util.Maybe as Maybe


{-| A transform to apply to the value in a slot.
-}
type Transform
    = NoTransform
    | UpperCase
    | Capitalize


{-| A style to be applied to some text.
-}
type Style
    = NoStyle
    | Em


{-| Get an element function that applies the given style and transform.
-}
transformedStyledElement : Transform -> Style -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
transformedStyledElement transform style attrs =
    styledElement style (transformAttrs transform ++ attrs)


{-| Get a element function that applies the given style.
-}
styledElement : Style -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
styledElement style =
    case style of
        NoStyle ->
            Html.span

        Em ->
            Html.em


{-| Get a class name that applies the given transform.
-}
transformClass : Transform -> Maybe String
transformClass transform =
    case transform of
        NoTransform ->
            Nothing

        UpperCase ->
            Just "upper-case"

        Capitalize ->
            Just "capitalize"


{-| Get an attribute list that applies the given transform.
-}
transformAttrs : Transform -> List (Html.Attribute msg)
transformAttrs =
    transformClass >> Maybe.map HtmlA.class >> Maybe.toList
