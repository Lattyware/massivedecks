module MassiveDecks.Card.Source.Cardcast exposing (empty, methods)

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


methods : PlayCode -> Source.Methods msg
methods playCode =
    { problem = \() -> problem playCode
    , details = \() -> details playCode
    , tooltip = \() -> tooltip playCode |> Just
    , logo = \() -> Just logo
    , name = \() -> "Cardcast"
    , editor = editor playCode
    , equals = equals playCode
    }


empty : Source.External
empty =
    "" |> playCode |> Source.Cardcast



{- Private -}


equals : PlayCode -> Source -> Bool
equals (PlayCode pc) source =
    case source of
        Source.Ex (Source.Cardcast (PlayCode other)) ->
            pc == other

        _ ->
            False


problem : PlayCode -> Maybe (Message msg)
problem (PlayCode pc) =
    if String.isEmpty pc then
        Strings.CardcastEmptyPlayCode |> Message.info |> Just

    else
        Nothing


editor : PlayCode -> Shared -> (Source.External -> msg) -> Html msg
editor (PlayCode pc) shared update =
    Wl.textField
        [ HtmlA.value pc
        , HtmlA.class "primary"
        , WlA.outlined
        , HtmlE.onInput (playCode >> Source.Cardcast >> update)
        , Strings.CardcastPlayCode |> Lang.label shared
        ]
        [ Html.span [ WlA.textFieldSlot WlA.BeforeText ] [ logo ] ]


details : PlayCode -> Source.Details
details (PlayCode pc) =
    { name = "Cardcast " ++ pc
    , url = Just (Url.crossOrigin "https://www.cardcastgame.com" [ "browse", "deck", pc ] [])
    }


tooltip : PlayCode -> ( String, Html msg )
tooltip (PlayCode pc) =
    ( "cardcast-" ++ pc, Html.span [] [ logo, Html.text pc ] )


logo : Html msg
logo =
    Html.span [ HtmlA.class "cardcast-logo" ] []
