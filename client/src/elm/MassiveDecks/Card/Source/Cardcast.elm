module MassiveDecks.Card.Source.Cardcast exposing
    ( generalMethods
    , methods
    )

import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card.Source.Cardcast.Model exposing (..)
import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import Url.Builder as Url
import Weightless as Wl
import Weightless.Attributes as WlA


methods : PlayCode -> Source.ExternalMethods msg
methods playCode =
    { name = name
    , logo = logo
    , empty = empty
    , problems = problems playCode
    , defaultDetails = details playCode
    , tooltip = tooltip playCode
    , editor = editor playCode
    , equals = equals playCode
    }


generalMethods : Source.ExternalGeneralMethods msg
generalMethods =
    { name = name
    , logo = logo
    , empty = empty
    }



{- Private -}


name : () -> MdString
name () =
    Strings.Cardcast


empty : () -> Source.External
empty () =
    "" |> playCode |> Source.Cardcast


equals : PlayCode -> Source.External -> Bool
equals (PlayCode pc) source =
    case source of
        Source.Cardcast (PlayCode other) ->
            pc == other


problems : PlayCode -> () -> List (Message msg)
problems (PlayCode pc) () =
    if String.isEmpty pc then
        [ Strings.CardcastEmptyPlayCode |> Message.info ]

    else
        []


editor : PlayCode -> Shared -> (Source.External -> msg) -> Html msg
editor (PlayCode pc) shared update =
    Wl.textField
        [ HtmlA.value pc
        , HtmlA.class "primary"
        , WlA.outlined
        , HtmlE.onInput (playCode >> Source.Cardcast >> update)
        , Strings.CardcastPlayCode |> Lang.label shared
        ]
        [ Html.span [ WlA.textFieldSlot WlA.BeforeText ] [ logoInternal ] ]


details : PlayCode -> Shared -> Source.Details
details (PlayCode pc) shared =
    { name = (() |> name |> Lang.string shared) ++ " " ++ pc
    , url = Just (Url.crossOrigin "https://www.cardcastgame.com" [ "browse", "deck", pc ] [])
    }


tooltip : PlayCode -> () -> Maybe ( String, Html msg )
tooltip (PlayCode pc) () =
    ( "cardcast-" ++ pc, Html.span [] [ logoInternal, Html.text pc ] ) |> Just


logo : () -> Maybe (Html msg)
logo () =
    logoInternal |> Just


logoInternal : Html msg
logoInternal =
    Html.span [ HtmlA.class "cardcast-logo" ] []
