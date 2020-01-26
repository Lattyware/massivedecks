module MassiveDecks.Pages.Lobby.Configure.Decks.Model exposing
    ( Config
    , Deck
    , Error
    , Model
    , Msg(..)
    )

import MassiveDecks.Card.Source.Model as Source


{-| A deck in the configuration, either loaded or not.
-}
type alias Deck =
    { source : Source.External, summary : Maybe Source.Summary }


{-| An error encountered while loading a deck.
-}
type alias Error =
    { reason : Source.LoadFailureReason
    , deck : Source.External
    }


{-| The model for the editor for decks.
-}
type alias Model =
    { toAdd : Source.External
    , errors : List Error
    }


{-| The configuration value for decks.
-}
type alias Config =
    List Deck


{-| Messages from user interaction.
-}
type Msg
    = Update Source.External
    | Add Source.External
    | Remove Source.External
