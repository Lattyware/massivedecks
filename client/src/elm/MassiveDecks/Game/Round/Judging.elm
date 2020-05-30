module MassiveDecks.Game.Round.Judging exposing (view)

import Dict
import Html.Attributes as HtmlA
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Play as Play
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Model exposing (Auth)
import MassiveDecks.Strings as Strings
import MassiveDecks.Util.Maybe as Maybe
import Set exposing (Set)


view : (Msg -> msg) -> Auth -> Shared -> Config -> Round.Judging -> RoundView msg
view wrap auth shared config round =
    let
        role =
            Player.role (Round.J round) auth.claims.uid

        { action, msg, instruction, isCzar } =
            case role of
                Player.RCzar ->
                    { action = Maybe.map (always Action.Judge) round.pick
                    , msg = \p -> p |> PickPlay |> wrap |> Just
                    , instruction = Strings.RevealPlaysInstruction
                    , isCzar = True
                    }

                Player.RPlayer ->
                    let
                        canBeLiked play =
                            Just play /= round.likeDetail.played && not (Set.member play round.likeDetail.liked)
                    in
                    { action = Maybe.andThen (\p -> Maybe.justIf (canBeLiked p) Action.Like) round.pick
                    , msg = \p -> p |> PickPlay |> wrap |> Maybe.justIf (canBeLiked p)
                    , instruction = Strings.WaitingForCzarInstruction
                    , isCzar = False
                    }

        picked =
            round.plays
                |> List.filter (\play -> Just play.id == round.pick)
                |> List.head
                |> Maybe.map (.responses >> Parts.fillsFromPlay)
                |> Maybe.withDefault Dict.empty

        details =
            round.plays |> List.map (playDetails shared config round.likeDetail.liked msg)
    in
    { instruction = Just instruction
    , action = action
    , content = details |> Plays.view [ ( "judging", True ), ( "is-czar", isCzar ) ] round.pick
    , slotAttrs = always []
    , fillCallWith = picked
    , roundAttrs = []
    }



{- Private -}


playDetails : Shared -> Config -> Set Play.Id -> (Play.Id -> Maybe msg) -> Play.Known -> Plays.Details msg
playDetails shared config liked msg { id, responses } =
    let
        maybeMsg =
            msg id

        cls =
            if maybeMsg /= Nothing then
                [ HtmlA.class "active" ]

            else
                []

        cards =
            responses
                |> List.map (\r -> Response.view shared config Card.Front [] r)

        attrs =
            [ HtmlA.class "liked" ] |> Maybe.justIf (Set.member id liked) |> Maybe.withDefault []
    in
    Plays.Details id cards maybeMsg (attrs ++ cls)
