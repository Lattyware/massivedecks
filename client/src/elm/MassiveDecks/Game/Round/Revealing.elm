module MassiveDecks.Game.Round.Revealing exposing (view)

import MassiveDecks.Card as Card
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (RoundView)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model as Configure
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Pages.Lobby.Model exposing (Auth)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe


view : Shared -> Auth -> List Configure.Deck -> Round.Revealing -> RoundView Global.Msg
view shared auth decks round =
    let
        role =
            Player.role (Round.R round) auth.claims.uid

        instruction =
            case role of
                Player.RCzar ->
                    Strings.RevealPlaysInstruction

                Player.RPlayer ->
                    Strings.WaitingForCzarInstruction

        slots =
            Card.slotCount round.call

        plays =
            round.plays |> List.map (playDetails shared decks slots (role == Player.RCzar))

        -- TODO: Last revealed.
        lastRevealed =
            []
    in
    { instruction = Just instruction
    , action = Nothing
    , content = plays |> Plays.view "revealing" Nothing
    , fillCallWith = lastRevealed
    }



{- Private -}


playDetails : Shared -> List Configure.Deck -> Int -> Bool -> Play -> Plays.Details Global.Msg
playDetails shared decks slots isCzar { id, responses } =
    let
        cards =
            responses
                |> Maybe.map (List.map (\r -> Card.view shared decks Card.Front [] (Card.R r)))
                |> Maybe.withDefault (List.repeat slots (Card.viewUnknownResponse []))
    in
    Plays.Details id cards (Reveal id |> Lobby.GameMsg |> Global.LobbyMsg |> Maybe.justIf isCzar) []
