module MassiveDecks.Game.Round.Revealing exposing (view)

import Dict exposing (Dict)
import Html.Attributes as HtmlA
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (RoundView)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Model exposing (Auth)
import MassiveDecks.Strings as Strings
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Maybe as Maybe
import Set exposing (Set)


view : (Msg -> msg) -> Auth -> Shared -> Dict User.Id User -> Config -> Round.Specific Round.Revealing -> RoundView msg
view wrap auth shared users config round =
    let
        role =
            Player.role round auth.claims.uid

        stage =
            round.stage

        { msg, action, instruction, isCzar } =
            case role of
                Player.RCzar ->
                    let
                        msgPick { id, responses } =
                            id |> Reveal |> wrap |> Maybe.justIf (responses == Nothing)
                    in
                    { msg = msgPick
                    , action = Nothing
                    , instruction = Strings.RevealPlaysInstruction
                    , isCzar = True
                    }

                Player.RPlayer ->
                    let
                        canBeLiked id =
                            (Just id /= stage.likeDetail.played) && not (Set.member id stage.likeDetail.liked)

                        msgPick { id, responses } =
                            id |> PickPlay |> wrap |> Maybe.justIf (canBeLiked id && (responses /= Nothing))
                    in
                    { msg = msgPick
                    , action = Maybe.andThen (\p -> Action.Like |> Maybe.justIf (canBeLiked p)) stage.pick
                    , instruction = Strings.WaitingForCzarInstruction
                    , isCzar = False
                    }

        slots =
            Call.slotCount round.call

        plays =
            stage.plays |> List.map (playDetails shared config slots msg)

        lastRevealed =
            case stage.plays |> List.filter (\p -> Just p.id == stage.lastRevealed) of
                play :: [] ->
                    play.responses |> Maybe.map Parts.fillsFromPlay

                _ ->
                    Nothing
    in
    { instruction = Just instruction
    , action = action
    , content = plays |> Plays.view shared users [ ( "revealing", True ), ( "is-czar", isCzar ) ] stage.likeDetail.liked stage.pick
    , slotAttrs = always []
    , fillCallWith = lastRevealed |> Maybe.withDefault Dict.empty
    , roundAttrs = []
    }



{- Private -}


playDetails : Shared -> Config -> Int -> (Play -> Maybe msg) -> Play -> Plays.Details msg
playDetails shared config slots msg play =
    let
        { id, responses } =
            play

        maybeMsg =
            msg play

        cards =
            responses
                |> Maybe.map (List.map (\r -> Response.view shared config Card.Front [] r))
                |> Maybe.withDefault (List.repeat slots (Response.viewUnknown shared []))
    in
    Plays.Details id cards maybeMsg Nothing
