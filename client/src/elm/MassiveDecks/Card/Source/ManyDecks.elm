module MassiveDecks.Card.Source.ManyDecks exposing
    ( generalMethods
    , methods
    )

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode as Json
import MassiveDecks.Card.Source.ManyDecks.Model as ManyDecks exposing (..)
import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components.Form.Message as Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing (DeckOrError)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.Util.Maybe as Maybe
import Material.Select as Select
import Material.TextField as TextField
import Url.Builder as Url


methods : DeckCode -> Source.ExternalMethods msg
methods dc =
    { name = name
    , logo = logo
    , empty = empty
    , id = id
    , messages = messages
    , problems = problems dc
    , defaultDetails = details dc
    , tooltip = tooltip dc
    , editor = editor dc
    , equals = equals dc
    }


generalMethods : Source.ExternalGeneralMethods msg
generalMethods =
    { name = name
    , logo = logo
    , empty = empty
    , id = id
    , messages = messages
    }



{- Private -}


id : () -> Source.General
id () =
    Source.GManyDecks


name : () -> MdString
name () =
    Strings.ManyDecks


empty : Shared -> Source.External
empty _ =
    "" |> deckCode |> Source.ManyDecks


equals : DeckCode -> Source.External -> Bool
equals dc source =
    case source of
        Source.ManyDecks other ->
            dc == other

        _ ->
            False


messages : () -> List (Message msg)
messages () =
    [ Strings.ManyDecksWhereToGet |> Message.info ]


problems : DeckCode -> () -> List (Message msg)
problems dc () =
    if (dc |> toString |> String.length) < 5 then
        [ Strings.ManyDecksDeckCodeShort |> Message.info ]

    else
        []


editor : DeckCode -> Shared -> List DeckOrError -> (Source.External -> msg) -> Maybe msg -> msg -> Html msg
editor dc shared _ update submit noOp =
    Html.div [ HtmlA.class "primary" ]
        [ TextField.view shared
            Strings.ManyDecksDeckCodeTitle
            TextField.Text
            (dc |> toString)
            [ HtmlE.onInput (deckCode >> Source.ManyDecks >> update)
            , HtmlE.keyCode
                |> Json.map (\k -> submit |> Maybe.andThen (Maybe.justIf (k == 13)) |> Maybe.withDefault noOp)
                |> HtmlE.on "keydown"
            ]
        ]


details : DeckCode -> Shared -> Source.Details
details dc shared =
    let
        url baseUrl =
            Url.crossOrigin baseUrl [ "decks", dc |> toString ] []
    in
    { name = (() |> name |> Lang.string shared) ++ " " ++ (dc |> toString)
    , url = shared.sources.manyDecks |> Maybe.map (.baseUrl >> url)
    , author = Nothing
    , translator = Nothing
    , language = Nothing
    }


tooltip : DeckCode -> (String -> List (Html msg) -> Html msg) -> Maybe ( String, Html msg )
tooltip dc tooltipRender =
    let
        forId =
            "many-decks-deck-code-" ++ toString dc

        content =
            [ Html.p [ HtmlA.class "source-id" ]
                [ logoInternal
                , Html.div [ HtmlA.class "many-decks-deck-code" ] [ dc |> toString |> Html.text ]
                ]
            ]
    in
    ( forId, content |> tooltipRender forId ) |> Just


logo : () -> Maybe (Html msg)
logo () =
    logoInternal |> Just


logoInternal : Html msg
logoInternal =
    Icon.boxOpen |> Icon.viewIcon
