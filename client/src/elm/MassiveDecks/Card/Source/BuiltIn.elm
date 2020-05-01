module MassiveDecks.Card.Source.BuiltIn exposing
    ( generalMethods
    , methods
    )

import Html as Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card.Source.BuiltIn.Model exposing (..)
import MassiveDecks.Card.Source.Methods as Source
import MassiveDecks.Card.Source.Model as Source exposing (Source)
import MassiveDecks.Components.Form.Message exposing (Message)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Decks.Model as Decks exposing (DeckOrError)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Util.Html as Html
import Weightless as Wl
import Weightless.Attributes as WlA


methods : Id -> Source.ExternalMethods msg
methods given =
    { name = name
    , logo = logo
    , empty = empty
    , id = id
    , problems = problems given
    , defaultDetails = details given
    , tooltip = tooltip given
    , editor = editor given
    , equals = equals given
    }


generalMethods : Source.ExternalGeneralMethods msg
generalMethods =
    { name = name
    , logo = logo
    , empty = empty
    , id = id
    }



{- Private -}


id : () -> String
id _ =
    "BuiltIn"


name : () -> MdString
name () =
    Strings.BuiltIn


empty : Shared -> Source.External
empty shared =
    shared.sources.builtIn
        |> Maybe.andThen (.decks >> List.head)
        |> Maybe.map .id
        |> Maybe.withDefault (Id "")
        |> Source.BuiltIn


equals : Id -> Source.External -> Bool
equals (Id given) source =
    case source of
        Source.BuiltIn (Id other) ->
            given == other

        _ ->
            False


problems : Id -> () -> List (Message msg)
problems _ () =
    []


editor : Id -> Shared -> List DeckOrError -> (Source.External -> msg) -> Html msg
editor (Id selectedId) shared _ update =
    case shared.sources.builtIn of
        Just { decks } ->
            let
                deck deckInfo =
                    case deckInfo.id of
                        Id other ->
                            Html.option
                                [ HtmlA.selected (selectedId == other)
                                , HtmlA.value other
                                ]
                                [ Html.text deckInfo.name ]
            in
            Html.div [ HtmlA.class "primary" ]
                [ Wl.select
                    [ HtmlA.id "built-in-selector"
                    , WlA.outlined
                    , Id >> Source.BuiltIn >> update |> HtmlE.onInput
                    ]
                    (decks |> List.map deck)
                ]

        Nothing ->
            Html.nothing


details : Id -> Shared -> Source.Details
details (Id given) shared =
    let
        isSame deckInfo =
            case deckInfo.id of
                Id other ->
                    given == other
    in
    { name =
        shared.sources.builtIn
            |> Maybe.andThen (.decks >> List.filter isSame >> List.head >> Maybe.map .name)
            |> Maybe.withDefault ""
    , url = Nothing
    }


tooltip : Id -> Shared -> Maybe ( String, Html msg )
tooltip (Id given) shared =
    ( "builtin-" ++ given, Html.span [] [ details (Id given) shared |> .name |> Html.text ] ) |> Just


logo : () -> Maybe (Html msg)
logo () =
    Nothing
