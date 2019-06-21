module MassiveDecks.Game.Rules exposing
    ( HouseRule
    , HouseRuleChange(..)
    , HouseRules
    , PackingHeat
    , Rando
    , Reboot
    , Rules
    , apply
    , packingHeat
    , rando
    , reboot
    )

{-| Game rules.
-}

import MassiveDecks.Strings as Strings exposing (MdString)


{-| The base rules for a game.
-}
type alias Rules =
    { handSize : Int
    , scoreLimit : Maybe Int
    , houseRules : HouseRules
    }


type alias HouseRules =
    { rando : Maybe Rando
    , packingHeat : Maybe PackingHeat
    , reboot : Maybe Reboot
    }


type alias PackingHeat =
    {}


type alias Reboot =
    { cost : Int }


type alias Rando =
    { number : Int }


type HouseRuleChange
    = RandoChange (Maybe Rando)
    | PackingHeatChange (Maybe PackingHeat)
    | RebootChange (Maybe Reboot)


apply : HouseRuleChange -> HouseRules -> HouseRules
apply change houseRules =
    case change of
        RandoChange c ->
            { houseRules | rando = c }

        PackingHeatChange c ->
            { houseRules | packingHeat = c }

        RebootChange c ->
            { houseRules | reboot = c }


type alias HouseRule a =
    { default : a
    , change : Maybe a -> HouseRuleChange
    , title : MdString
    , description : Maybe a -> MdString
    , extract : HouseRules -> Maybe a
    , insert : Maybe a -> HouseRules -> HouseRules
    }


rando : HouseRule Rando
rando =
    { default = { number = 1 }
    , change = RandoChange
    , title = Strings.HouseRuleRandoCardrissian
    , description = always Strings.HouseRuleRandoCardrissianDescription
    , extract = .rando
    , insert = \r -> \hr -> { hr | rando = r }
    }


reboot : HouseRule Reboot
reboot =
    let
        description =
            Maybe.map .cost
                >> Maybe.map (\c -> { cost = Just c })
                >> Maybe.withDefault { cost = Nothing }
                >> Strings.HouseRuleRebootDescription
    in
    { default = { cost = 1 }
    , change = RebootChange
    , title = Strings.HouseRuleReboot
    , description = description
    , extract = .reboot
    , insert = \r -> \hr -> { hr | reboot = r }
    }


packingHeat : HouseRule PackingHeat
packingHeat =
    { default = {}
    , change = PackingHeatChange
    , title = Strings.HouseRulePackingHeat
    , description = always Strings.HouseRulePackingHeatDescription
    , extract = .packingHeat
    , insert = \ph -> \hr -> { hr | packingHeat = ph }
    }
