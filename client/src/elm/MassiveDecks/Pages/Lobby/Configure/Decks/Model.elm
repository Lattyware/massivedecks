module MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing
    ( Config
    , Deck
    , DeckOrError
    , Error
    , GetSummary
    , Id(..)
    , Model
    , Msg(..)
    , deckToDeckOrError
    , errorToDeckOrError
    )

import MassiveDecks.Card.Source.Model as Source exposing (Source)


type Id
    = All


{-| Summaries from the deck list.
-}
type alias GetSummary =
    Source -> Maybe Source.Summary


{-| A deck in the configuration, either loaded or not.
-}
type alias Deck =
    { source : Source.External, summary : Maybe Source.Summary }


{-| An error encountered while loading a deck.
-}
type alias Error =
    { source : Source.External, reason : Source.LoadFailureReason }


{-| A deck or an error.
-}
type alias DeckOrError =
    { source : Source.External
    , result : Result Source.LoadFailureReason (Maybe Source.Summary)
    }


deckToDeckOrError : Deck -> DeckOrError
deckToDeckOrError { source, summary } =
    { source = source, result = Ok summary }


errorToDeckOrError : Error -> DeckOrError
errorToDeckOrError { source, reason } =
    { source = source, result = Err reason }


{-| The model for the editor for decks.
-}
type alias Model =
    { toAdd : Source.External
    }


{-| The configuration value for decks.
-}
type alias Config =
    List DeckOrError


{-| Messages from user interaction.
-}
type Msg
    = Update Source.External
    | Add Source.External
    | Remove Int
    | NoOp
