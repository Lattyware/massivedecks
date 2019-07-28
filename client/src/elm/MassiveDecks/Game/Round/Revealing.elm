module MassiveDecks.Game.Round.Revealing exposing (view)

import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (RoundView)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Messages as Global
import MassiveDecks.Pages.Lobby.Configure.Model as Configure exposing (Config)
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Pages.Lobby.Model exposing (Auth)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe


view : Auth -> Config -> Round.Revealing -> RoundView Global.Msg
view auth config round =
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
            Call.slotCount round.call

        plays =
            round.plays |> List.map (playDetails config slots (role == Player.RCzar))

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


playDetails : Config -> Int -> Bool -> Play -> Plays.Details Global.Msg
playDetails config slots isCzar { id, responses } =
    let
        cards =
            responses
                |> Maybe.map (List.map (\r -> Response.view config Card.Front [] r))
                |> Maybe.withDefault (List.repeat slots (Response.viewUnknown []))
    in
    Plays.Details id cards (Reveal id |> Lobby.GameMsg |> Global.LobbyMsg |> Maybe.justIf isCzar) []
