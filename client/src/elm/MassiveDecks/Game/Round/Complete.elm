module MassiveDecks.Game.Round.Complete exposing (view)

import Dict exposing (Dict)
import Html exposing (Html)
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Play as Play
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Strings as Strings
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Maybe as Maybe
import Set


view : (Msg -> msg) -> Shared -> Bool -> Config -> Dict User.Id User -> Round.Specific Round.Complete -> RoundView msg
view wrap shared nextRoundReady config users round =
    let
        stage =
            round.stage

        winning =
            stage.plays |> Dict.get stage.winner

        canBeLiked play =
            Just play /= stage.likeDetail.played && not (Set.member play stage.likeDetail.liked)

        likeIfCanBeLiked pick =
            Action.Like |> Maybe.justIf (canBeLiked pick)

        pickMsg play =
            play |> PickPlay |> wrap |> Maybe.justIf (canBeLiked play)

        likeAction =
            stage.pick |> Maybe.andThen likeIfCanBeLiked

        playById playId =
            Dict.get playId stage.plays |> Maybe.map (Tuple.pair playId)
    in
    { instruction = Strings.AdvanceRoundInstruction |> Maybe.justIf nextRoundReady
    , action =
        Maybe.first
            [ Action.Advance |> Maybe.justIf nextRoundReady
            , likeAction
            ]
    , content =
        stage.playOrder
            |> List.filterMap playById
            |> List.map (details shared config stage.winner pickMsg)
            |> Plays.view shared users [ ( "complete", True ) ] stage.likeDetail.liked stage.pick
    , slotAttrs = always []
    , fillCallWith = winning |> Maybe.map (.play >> Parts.fillsFromPlay) |> Maybe.withDefault Dict.empty
    , roundAttrs = []
    }


details : Shared -> Config -> User.Id -> (Play.Id -> Maybe msg) -> ( Play.Id, Play.WithDetails ) -> Plays.Details msg
details shared config winner maybeMsg ( id, { play, playedBy, likes } ) =
    let
        cards =
            play |> List.map (\r -> Html.li [] [ Response.view shared config Card.Front [] r ])

        specialRole =
            if winner == playedBy then
                Just Plays.Winner

            else
                Nothing

        byLine =
            Plays.ByLine playedBy specialRole likes
    in
    Plays.Details id cards (id |> maybeMsg) (Just byLine)
