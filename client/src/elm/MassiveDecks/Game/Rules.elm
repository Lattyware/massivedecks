module MassiveDecks.Game.Rules exposing
    ( ComedyWriter
    , HouseRule
    , HouseRuleChange(..)
    , HouseRules
    , PackingHeat
    , Rando
    , Reboot
    , Rules
    , TimeLimitMode(..)
    , TimeLimits
    , apply
    , comedyWriter
    , defaultTimeLimits
    , getTimeLimitByStage
    , packingHeat
    , rando
    , reboot
    , setTimeLimitByStage
    )

{-| Game rules.
-}

import MassiveDecks.Game.Round as Round
import MassiveDecks.Strings as Strings exposing (MdString)


{-| The base rules for a game.
-}
type alias Rules =
    { handSize : Int
    , scoreLimit : Maybe Int
    , houseRules : HouseRules
    , timeLimits : TimeLimits
    }


type alias HouseRules =
    { rando : Maybe Rando
    , packingHeat : Maybe PackingHeat
    , reboot : Maybe Reboot
    , comedyWriter : Maybe ComedyWriter
    }


type TimeLimitMode
    = Hard
    | Soft


type alias TimeLimits =
    { mode : TimeLimitMode
    , playing : Maybe Float
    , revealing : Maybe Float
    , judging : Maybe Float
    , complete : Float
    }


defaultTimeLimits : TimeLimits
defaultTimeLimits =
    { mode = Soft
    , playing = Just 60
    , revealing = Just 30
    , judging = Just 30
    , complete = 2
    }


setTimeLimitByStage : Round.Stage -> Maybe Float -> TimeLimits -> TimeLimits
setTimeLimitByStage stage timeLimit timeLimits =
    case stage of
        Round.SPlaying ->
            { timeLimits | playing = timeLimit }

        Round.SRevealing ->
            { timeLimits | revealing = timeLimit }

        Round.SJudging ->
            { timeLimits | judging = timeLimit }

        Round.SComplete ->
            { timeLimits | complete = timeLimit |> Maybe.withDefault timeLimits.complete }


getTimeLimitByStage : Round.Stage -> TimeLimits -> Maybe Float
getTimeLimitByStage stage timeLimits =
    case stage of
        Round.SPlaying ->
            timeLimits.playing

        Round.SRevealing ->
            timeLimits.revealing

        Round.SJudging ->
            timeLimits.judging

        Round.SComplete ->
            Just timeLimits.complete


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


type HouseRuleChange
    = RandoChange (Maybe Rando)
    | PackingHeatChange (Maybe PackingHeat)
    | RebootChange (Maybe Reboot)
    | ComedyWriterChange (Maybe ComedyWriter)


apply : HouseRuleChange -> HouseRules -> HouseRules
apply change houseRules =
    case change of
        RandoChange c ->
            { houseRules | rando = c }

        PackingHeatChange c ->
            { houseRules | packingHeat = c }

        RebootChange c ->
            { houseRules | reboot = c }

        ComedyWriterChange c ->
            { houseRules | comedyWriter = c }


type alias HouseRule a =
    { default : a
    , change : Maybe a -> HouseRuleChange
    , title : MdString
    , description : Maybe a -> MdString
    , extract : HouseRules -> Maybe a
    , insert : Maybe a -> HouseRules -> HouseRules
    , validate : a -> Bool
    }


rando : HouseRule Rando
rando =
    { default = { number = 1 }
    , change = RandoChange
    , title = Strings.HouseRuleRandoCardrissian
    , description = always Strings.HouseRuleRandoCardrissianDescription
    , extract = .rando
    , insert = \r -> \hr -> { hr | rando = r }
    , validate = \r -> r.number >= 1 && r.number <= 10
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
    , validate = \r -> r.cost >= 1 && r.cost <= 50
    }


packingHeat : HouseRule PackingHeat
packingHeat =
    { default = {}
    , change = PackingHeatChange
    , title = Strings.HouseRulePackingHeat
    , description = always Strings.HouseRulePackingHeatDescription
    , extract = .packingHeat
    , insert = \ph -> \hr -> { hr | packingHeat = ph }
    , validate = \_ -> True
    }


comedyWriter : HouseRule ComedyWriter
comedyWriter =
    { default = { number = 3, exclusive = False }
    , change = ComedyWriterChange
    , title = Strings.HouseRuleComedyWriter
    , description = always Strings.HouseRuleComedyWriterDescription
    , extract = .comedyWriter
    , insert = \cw -> \hr -> { hr | comedyWriter = cw }
    , validate = \r -> r.number >= 1 && r.number <= 99999
    }
