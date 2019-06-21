module MassiveDecks.Card.Source.Model exposing
    ( Details
    , External(..)
    , LoadFailureReason(..)
    , Source(..)
    , Summary
    )

import MassiveDecks.Card.Source.Cardcast.Model as Cardcast


{-| Details on where game data came from.
-}
type Source
    = Ex External
    | Fake


{-| An external source.
-}
type External
    = Cardcast Cardcast.PlayCode


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
