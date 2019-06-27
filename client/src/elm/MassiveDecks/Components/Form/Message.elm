module MassiveDecks.Components.Form.Message exposing
    ( Fix
    , Message
    , Severity(..)
    , error
    , errorWithFix
    , info
    , none
    , view
    , warning
    )

import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Components as Components
import MassiveDecks.Model exposing (..)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang


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


view : Shared -> Message msg -> Maybe (Html msg)
view shared msg =
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


none : Message msg
none =
    Nothing



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
                    [ Html.text " ", Components.linkButton [ msg |> HtmlE.onClick ] [ text |> Lang.html shared ] ]

                Nothing ->
                    []
    in
    Html.span [ HtmlA.class class ]
        [ Icon.viewStyled [ Icon.fw ] icon
        , Html.span [] ((description |> Lang.html shared) :: fixLink)
        ]
