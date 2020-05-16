module MassiveDecks.Card.Source.Cardcast exposing
    ( generalMethods
    , methods
    )

import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode as Json
import MassiveDecks.Card.Source.Cardcast.Model exposing (..)
import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (DeckOrError)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Maybe as Maybe
import Material.TextField as TextField
import Url.Builder as Url


methods : PlayCode -> Source.ExternalMethods msg
methods playCode =
    { name = name
    , logo = logo
    , empty = empty
    , id = id
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
    , id = id
    }



{- Private -}


id : () -> Source.General
id () =
    Source.GCardcast


name : () -> MdString
name () =
    Strings.Cardcast


empty : Shared -> Source.External
empty _ =
    "" |> playCode |> Source.Cardcast


equals : PlayCode -> Source.External -> Bool
equals (PlayCode pc) source =
    case source of
        Source.Cardcast (PlayCode other) ->
            pc == other

        _ ->
            False


problems : PlayCode -> () -> List (Message msg)
problems (PlayCode pc) () =
    if String.isEmpty pc then
        [ Strings.CardcastEmptyPlayCode |> Message.info ]

    else
        []


editor : PlayCode -> Shared -> List DeckOrError -> (Source.External -> msg) -> Maybe msg -> msg -> Html msg
editor (PlayCode pc) shared existing update submit noOp =
    let
        notAlreadyInGame potential =
            case potential of
                Source.Cardcast playCode ->
                    let
                        notSameDeck { source } =
                            equals playCode source |> not
                    in
                    playCode |> Maybe.justIf (existing |> List.all notSameDeck)

                _ ->
                    Nothing

        recentDeck (PlayCode recent) =
            Html.option [ HtmlA.value recent ] []
    in
    Html.div [ HtmlA.class "primary" ]
        [ Html.datalist [ HtmlA.id "cardcast-recent-decks" ]
            (shared.settings.settings.recentDecks |> List.filterMap notAlreadyInGame |> List.map recentDeck)
        , TextField.view shared
            Strings.CardcastPlayCode
            TextField.Text
            pc
            [ HtmlA.list "cardcast-recent-decks"
            , HtmlE.onInput (playCode >> Source.Cardcast >> update)
            , HtmlE.keyCode
                |> Json.map (\k -> submit |> Maybe.andThen (Maybe.justIf (k == 13)) |> Maybe.withDefault noOp)
                |> HtmlE.on "keydown"
            ]
        ]


details : PlayCode -> Shared -> Source.Details
details (PlayCode pc) shared =
    { name = (() |> name |> Lang.string shared) ++ " " ++ pc
    , url = Just (Url.crossOrigin "https://www.cardcastgame.com" [ "browse", "deck", pc ] [])
    , author = Nothing
    , translator = Nothing
    , language = Nothing
    }


tooltip : PlayCode -> (String -> List (Html msg) -> Html msg) -> Maybe ( String, Html msg )
tooltip (PlayCode pc) tooltipRender =
    let
        forId =
            "cardcast-" ++ pc
    in
    ( forId, [ Html.p [ HtmlA.class "play-code" ] [ logoInternal, Html.text pc ] ] |> tooltipRender forId ) |> Just


logo : () -> Maybe (Html msg)
logo () =
    logoInternal |> Just


logoInternal : Html msg
logoInternal =
    Html.span [ HtmlA.class "cardcast-logo" ] []
