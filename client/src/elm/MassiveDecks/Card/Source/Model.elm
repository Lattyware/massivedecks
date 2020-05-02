module MassiveDecks.Card.Source.Model exposing
    ( BuiltInDeck
    , BuiltInInfo
    , Details
    , External(..)
    , Info
    , LoadFailureReason(..)
    , Source(..)
    , Summary
    )

import MassiveDecks.Card.Source.BuiltIn.Model as BuiltIn
import MassiveDecks.Card.Source.Cardcast.Model as Cardcast


{-| Details on where game data came from.

    - `Ex`: External sources are the main sources of cards users can add.
    - `Player`: These are cards written by the given player.
    - `Fake`: These are cards used for presentation outside of a game environment.

-}
type Source
    = Ex External
    | Custom
    | Fake (Maybe String)


{-| An external source.

"External" might be a bit of a poor name here. What this mostly means is that the user can add these as decks. Other
sources are more limited and specific.

    - `Cardcast`: Decks from the Cardcast database.

-}
type External
    = BuiltIn BuiltIn.Id
    | Cardcast Cardcast.PlayCode


{-| A summary of the contents of the source deck.
-}
type alias Summary =
    { details : Details
    , calls : Int
    , responses : Int
    }


{-| Details about the source deck.
-}
type alias Details =
    { name : String
    , url : Maybe String
    }


{-| The reason a source failed to load.
-}
type LoadFailureReason
    = SourceFailure
    | NotFound


{-| Information about what sources are available from the server.
-}
type alias Info =
    { builtIn : Maybe BuiltInInfo
    , cardcast : Bool
    }


type alias BuiltInInfo =
    { decks : List BuiltInDeck }


type alias BuiltInDeck =
    { name : String, id : BuiltIn.Id }
