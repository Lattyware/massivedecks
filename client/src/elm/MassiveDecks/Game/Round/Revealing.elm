module MassiveDecks.Game.Round.Revealing exposing (view)

import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play exposing (Play)
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (RoundView)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Model exposing (Auth)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe


view : (Msg -> msg) -> Auth -> Shared -> Config -> Round.Revealing -> RoundView msg
view wrap auth shared config round =
    let
        role =
            Player.role (Round.R round) auth.claims.uid

        ( instruction, isCzar ) =
            case role of
                Player.RCzar ->
                    ( Strings.RevealPlaysInstruction, True )

                Player.RPlayer ->
                    ( Strings.WaitingForCzarInstruction, False )

        slots =
            Call.slotCount round.call

        plays =
            round.plays |> List.map (playDetails wrap shared config slots (role == Player.RCzar))

        lastRevealed =
            case round.plays |> List.filter (\p -> Just p.id == round.lastRevealed) of
                play :: [] ->
                    play.responses

                _ ->
                    Nothing
    in
    { instruction = Just instruction
    , action = Nothing
    , content = plays |> Plays.view [ ( "revealing", True ), ( "is-czar", isCzar ) ] Nothing
    , fillCallWith = lastRevealed |> Maybe.withDefault []
    }



{- Private -}


playDetails : (Msg -> msg) -> Shared -> Config -> Int -> Bool -> Play -> Plays.Details msg
playDetails wrap shared config slots isCzar { id, responses } =
    let
        cards =
            responses
                |> Maybe.map (List.map (\r -> Response.view shared config Card.Front [] r))
                |> Maybe.withDefault (List.repeat slots (Response.viewUnknown shared []))
    in
    Plays.Details id cards (Reveal id |> wrap |> Maybe.justIf isCzar) []
