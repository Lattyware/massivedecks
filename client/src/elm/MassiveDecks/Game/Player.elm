module MassiveDecks.Game.Player exposing
    ( PlayState(..)
    , Player
    , Presence(..)
    , Role(..)
    , Score
    , default
    , isCzar
    , playState
    , role
    , roleDescription
    )

import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.User as User
import Set


{-| A player in the game.
-}
type alias Player =
    { score : Score
    , likes : Int
    , presence : Presence
    }


default : Player
default =
    { score = 0
    , likes = 0
    , presence = Active
    }


{-| A score in the game.
-}
type alias Score =
    Int


{-| If the user is temporarily away from the game.
-}
type Presence
    = Active
    | Away


{-| The role the player currently has in the game.
-}
type Role
    = RCzar
    | RPlayer


roleDescription : Role -> MdString
roleDescription toDescribe =
    case toDescribe of
        RCzar ->
            Strings.Czar

        RPlayer ->
            Strings.noun Strings.Player 1


{-| The state of a player in regards to playing into a round.
-}
type PlayState
    = NotInRound
    | Playing
    | Played


role : Round.Specific stageDetails -> User.Id -> Role
role round id =
    if isCzar round id then
        RCzar

    else
        RPlayer


isCzar : Round.Specific stageDetails -> User.Id -> Bool
isCzar round id =
    (round |> .czar) == id


playState : Round.Specific Round.Playing -> User.Id -> PlayState
playState round id =
    if Set.member id round.players then
        if Set.member id round.stage.played then
            Played

        else
            Playing

    else
        NotInRound
