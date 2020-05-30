module MassiveDecks.Game.Round.Revealing exposing (view)

import Dict
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
import MassiveDecks.Util.Maybe as Maybe
import Set exposing (Set)


view : (Msg -> msg) -> Auth -> Shared -> Config -> Round.Revealing -> RoundView msg
view wrap auth shared config round =
    let
        role =
            Player.role (Round.R round) auth.claims.uid

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
                            (Just id /= round.likeDetail.played) && not (Set.member id round.likeDetail.liked)

                        msgPick { id, responses } =
                            id |> PickPlay |> wrap |> Maybe.justIf (canBeLiked id && (responses /= Nothing))
                    in
                    { msg = msgPick
                    , action = Maybe.andThen (\p -> Action.Like |> Maybe.justIf (canBeLiked p)) round.pick
                    , instruction = Strings.WaitingForCzarInstruction
                    , isCzar = False
                    }

        slots =
            Call.slotCount round.call

        plays =
            round.plays |> List.map (playDetails shared config round.likeDetail.liked slots msg)

        lastRevealed =
            case round.plays |> List.filter (\p -> Just p.id == round.lastRevealed) of
                play :: [] ->
                    play.responses |> Maybe.map Parts.fillsFromPlay

                _ ->
                    Nothing
    in
    { instruction = Just instruction
    , action = action
    , content = plays |> Plays.view [ ( "revealing", True ), ( "is-czar", isCzar ) ] round.pick
    , slotAttrs = always []
    , fillCallWith = lastRevealed |> Maybe.withDefault Dict.empty
    , roundAttrs = []
    }



{- Private -}


playDetails : Shared -> Config -> Set Play.Id -> Int -> (Play -> Maybe msg) -> Play -> Plays.Details msg
playDetails shared config liked slots msg play =
    let
        { id, responses } =
            play

        maybeMsg =
            msg play

        cls =
            if maybeMsg /= Nothing then
                [ HtmlA.class "active" ]

            else
                []

        cards =
            responses
                |> Maybe.map (List.map (\r -> Response.view shared config Card.Front [] r))
                |> Maybe.withDefault (List.repeat slots (Response.viewUnknown shared []))

        attrs =
            [ HtmlA.class "liked" ] |> Maybe.justIf (Set.member id liked) |> Maybe.withDefault []
    in
    Plays.Details id cards maybeMsg (attrs ++ cls)
