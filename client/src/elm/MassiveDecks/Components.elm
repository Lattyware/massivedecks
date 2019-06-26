module MassiveDecks.Components exposing
    ( Fix
    , Message
    , Severity(..)
    , error
    , errorWithFix
    , floatingActionButton
    , formSection
    , iconButton
    , iconButtonStyled
    , info
    , linkButton
    , message
    , warning
    )

{-| Reusable interface elements.
-}

import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Attributes.Aria as Aria
import Html.Events as HtmlE
import MassiveDecks.Model exposing (..)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import Weightless as Wl
import Weightless.Attributes as WlA


{-| A section containing inputs and messages..
-}
formSection : Shared -> String -> Html msg -> List (Message msg) -> Html msg
formSection shared id component messages =
    Html.div [ HtmlA.id id, HtmlA.class "form-section" ] (component :: (messages |> List.filterMap (message shared)))


type alias Fix msg =
    { text : MdString
    , msg : msg
    }


type Severity
    = Info
    | Warning
    | Error


type alias Message msg =
    Maybe (InternalMessage msg)


message : Shared -> Message msg -> Maybe (Html msg)
message shared msg =
    msg |> Maybe.map (internalMessage shared)


info : MdString -> Message msg
info mdString =
    Just
        { severity = Info
        , description = mdString
        , fix = Nothing
        }


warning : MdString -> Message msg
warning mdString =
    Just
        { severity = Warning
        , description = mdString
        , fix = Nothing
        }


error : MdString -> Message msg
error mdString =
    Just
        { severity = Error
        , description = mdString
        , fix = Nothing
        }


errorWithFix : MdString -> MdString -> msg -> Message msg
errorWithFix errorString fixString fix =
    Just
        { severity = Error
        , description = errorString
        , fix = Just { text = fixString, msg = fix }
        }


linkButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
linkButton attrs contents =
    Html.span (HtmlA.class "link-button" :: Aria.role "button" :: HtmlA.tabindex 0 :: attrs) contents



--Html.button (HtmlA.class "link-button" :: attrs) contents


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



{- Private -}


type alias InternalMessage msg =
    { severity : Severity
    , description : MdString
    , fix : Maybe (Fix msg)
    }


internalMessage : Shared -> InternalMessage msg -> Html msg
internalMessage shared { severity, description, fix } =
    let
        ( class, icon ) =
            case severity of
                Info ->
                    ( "info", Icon.infoCircle )

                Warning ->
                    ( "warning", Icon.exclamationTriangle )

                Error ->
                    ( "inline-error", Icon.exclamationCircle )

        fixLink =
            case fix of
                Just { text, msg } ->
                    [ Html.text " ", linkButton [ msg |> HtmlE.onClick ] [ text |> Lang.html shared ] ]

                Nothing ->
                    []
    in
    Html.span [ HtmlA.class class ]
        [ Icon.viewStyled [ Icon.fw ] icon
        , Html.span [] ((description |> Lang.html shared) :: fixLink)
        ]
