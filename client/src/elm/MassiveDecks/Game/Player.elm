module MassiveDecks.Game.Player exposing
    ( Control(..)
    , PlayState(..)
    , Player
    , Role(..)
    , Score
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
    { control : Control
    , score : Score
    }


{-| A score in the game.
-}
type alias Score =
    Int


{-| How the player is being controlled.
-}
type Control
    = Human
    | Computer


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
            Strings.Player


{-| The state of a player in regards to playing into a round.
-}
type PlayState
    = NotInRound
    | Playing
    | Played


role : Round -> User.Id -> Role
role round id =
    if isCzar round id then
        RCzar

    else
        RPlayer


isCzar : Round -> User.Id -> Bool
isCzar round id =
    (round |> Round.data |> .czar) == id


playState : Round.Playing -> User.Id -> PlayState
playState round id =
    if Set.member id round.players then
        if Set.member id round.played then
            Played

        else
            Playing

    else
        NotInRound
