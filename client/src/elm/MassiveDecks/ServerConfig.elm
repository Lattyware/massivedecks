module MassiveDecks.ServerConfig exposing
    ( Adverts
    , ServerConfig
    )

import MassiveDecks.Card.Source.Model as Source


type alias Adverts =
    { manyDecks : Bool
    , atTheParty : Bool
    }


type alias ServerConfig =
    { serverVersion : String
    , sourceInfo : Source.Info
    , adverts : Adverts
    }
