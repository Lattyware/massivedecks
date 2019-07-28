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
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Components as Components
import MassiveDecks.Model exposing (..)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import Svg.Attributes as Svg


type alias Fix msg =
    { description : MdString
    , icon : Icon
    , action : msg
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
        , fixes = []
        }


warning : MdString -> Message msg
warning mdString =
    Just
        { severity = Warning
        , description = mdString
        , fixes = []
        }


error : MdString -> Message msg
error mdString =
    Just
        { severity = Error
        , description = mdString
        , fixes = []
        }


errorWithFix : MdString -> List (Fix msg) -> Message msg
errorWithFix errorString fixes =
    Just
        { severity = Error
        , description = errorString
        , fixes = fixes
        }


none : Message msg
none =
    Nothing



{- Private -}


type alias InternalMessage msg =
    { severity : Severity
    , description : MdString
    , fixes : List (Fix msg)
    }


internalMessage : Shared -> InternalMessage msg -> Html msg
internalMessage shared { severity, description, fixes } =
    let
        ( class, icon ) =
            case severity of
                Info ->
                    ( "info", Icon.infoCircle )

                Warning ->
                    ( "warning", Icon.exclamationTriangle )

                Error ->
                    ( "inline-error", Icon.exclamationCircle )
    in
    Html.span [ HtmlA.class class ]
        [ Icon.viewStyled [ Icon.fw, Svg.class "message-type-icon" ] icon
        , Html.span [] [ description |> Lang.html shared ]
        , Html.ul [ HtmlA.class "fixes" ] (fixes |> List.map (viewFix shared))
        ]


viewFix : Shared -> Fix msg -> Html msg
viewFix shared { icon, description, action } =
    Html.li []
        [ Components.iconButton
            [ action |> HtmlE.onClick
            , description |> Lang.title shared
            ]
            icon
        ]
