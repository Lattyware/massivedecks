module MassiveDecks.Game.Rules exposing
    ( ComedyWriter
    , HappyEnding
    , HouseRules
    , NeverHaveIEver
    , PackingHeat
    , Rando
    , Reboot
    , Rules
    , Stage
    , Stages
    , TimeLimitMode(..)
    )

{-| Game rules.
-}


{-| The base rules for a game.
-}
type alias Rules =
    { handSize : Int
    , scoreLimit : Maybe Int
    , houseRules : HouseRules
    , stages : Stages
    }


type alias HouseRules =
    { rando : Maybe Rando
    , packingHeat : Maybe PackingHeat
    , reboot : Maybe Reboot
    , comedyWriter : Maybe ComedyWriter
    , neverHaveIEver : Maybe NeverHaveIEver
    , happyEnding : Maybe HappyEnding
    }


type TimeLimitMode
    = Hard
    | Soft


type alias Stage =
    { duration : Maybe Int
    , after : Int
    }


type alias Stages =
    { mode : TimeLimitMode
    , playing : Stage
    , revealing : Maybe Stage
    , judging : Stage
    }


type alias PackingHeat =
    {}


type alias Reboot =
    { cost : Int }


type alias Rando =
    { number : Int }


type alias ComedyWriter =
    { number : Int
    , exclusive : Bool
    }


type alias NeverHaveIEver =
    {}


type alias HappyEnding =
    {}
