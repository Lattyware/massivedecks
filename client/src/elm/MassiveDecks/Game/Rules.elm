module MassiveDecks.Game.Rules exposing
    ( ComedyWriter
    , HouseRules
    , PackingHeat
    , Rando
    , Reboot
    , Rules
    , TimeLimitMode(..)
    , TimeLimits
    , default
    , defaultTimeLimits
    , getTimeLimitByStage
    , setTimeLimitByStage
    )

{-| Game rules.
-}

import MassiveDecks.Game.Round as Round


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
    , playing : Maybe Int
    , revealing : Maybe Int
    , judging : Maybe Int
    , complete : Int
    }


default : Rules
default =
    { handSize = 10
    , scoreLimit = Just 25
    , houseRules =
        { rando = Nothing
        , packingHeat = Nothing
        , reboot = Nothing
        , comedyWriter = Nothing
        }
    , timeLimits = defaultTimeLimits
    }


defaultTimeLimits : TimeLimits
defaultTimeLimits =
    { mode = Soft
    , playing = Just 60
    , revealing = Just 30
    , judging = Just 30
    , complete = 2
    }


setTimeLimitByStage : Round.Stage -> Maybe Int -> TimeLimits -> TimeLimits
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


getTimeLimitByStage : Round.Stage -> TimeLimits -> Maybe Int
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
