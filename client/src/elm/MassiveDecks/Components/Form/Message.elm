module MassiveDecks.Components.Form.Message exposing
    ( Fix
    , Message
    , Severity(..)
    , error
    , errorWithFix
    , info
    , infoWithFix
    , mdError
    , none
    , view
    , warning
    )

import FontAwesome as Icon exposing (Icon)
import FontAwesome.Attributes as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import MassiveDecks.Icon as Icon
import MassiveDecks.Model exposing (..)
import MassiveDecks.Models.MdError as MdError exposing (MdError)
import MassiveDecks.Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import Material.IconButton as IconButton
import Svg.Attributes as Svg


type alias Fix msg =
    { description : MdString
    , icon : Icon Icon.WithoutId
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


infoWithFix : MdString -> List (Fix msg) -> Message msg
infoWithFix mdString fixes =
    Just
        { severity = Info
        , description = mdString
        , fixes = fixes
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


mdError : MdError -> Message msg
mdError e =
    e |> MdError.describe |> error


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
                    ( "info", Icon.info )

                Warning ->
                    ( "warning", Icon.warning )

                Error ->
                    ( "inline-error", Icon.bug )
    in
    Html.span [ HtmlA.class class ]
        [ icon |> Icon.styled [ Icon.fw, Svg.class "message-type-icon" ] |> Icon.view
        , Html.span [] [ description |> Lang.html shared ]
        , Html.ul [ HtmlA.class "fixes" ] (fixes |> List.map (viewFix shared))
        ]


viewFix : Shared -> Fix msg -> Html msg
viewFix shared { icon, description, action } =
    Html.li []
        [ IconButton.view (icon |> Icon.view)
            (description |> Lang.string shared)
            (Just action)
        ]
