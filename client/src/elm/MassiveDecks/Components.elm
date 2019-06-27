module MassiveDecks.Components exposing
    ( floatingActionButton
    , iconButton
    , iconButtonStyled
    , linkButton
    )

{-| Reusable interface elements.
-}

import FontAwesome.Icon as Icon exposing (Icon)
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Attributes.Aria as Aria
import Weightless as Wl
import Weightless.Attributes as WlA


{-| Something that looks like a link but is actually a button suitable for handling events on click.
-}
linkButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
linkButton attrs contents =
    Html.span (HtmlA.class "link-button" :: Aria.role "button" :: HtmlA.tabindex 0 :: attrs) contents


{-| A button that is just an icon.
-}
iconButton : List (Html.Attribute msg) -> Icon -> Html msg
iconButton attrs icon =
    iconButtonStyled attrs ( [], icon )


{-| A button that is just an icon with styles on the icon.
-}
iconButtonStyled : List (Html.Attribute msg) -> ( List (Html.Attribute msg), Icon ) -> Html msg
iconButtonStyled attrs ( styles, icon ) =
    Wl.button (List.concat [ [ WlA.fab, WlA.inverted, WlA.flat ], attrs ]) [ Icon.viewStyled styles icon ]


{-| A circular button designed to be the primary action on a page.
Only one of these should exist on screen at any time.
-}
floatingActionButton : List (Html.Attribute msg) -> Icon -> Html msg
floatingActionButton attrs icon =
    Wl.button (List.concat [ [ WlA.fab ], attrs ]) [ Icon.view icon ]
