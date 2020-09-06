module MassiveDecks.Game.Round.Complete exposing (view)

import Dict exposing (Dict)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Keyed as HtmlK
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Play as Play
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Player as Player
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Model exposing (Auth)
import MassiveDecks.Strings as Strings
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Maybe as Maybe
import Set


view : (Msg -> msg) -> Shared -> Auth -> Bool -> Config -> Dict User.Id User -> Round.Specific Round.Complete -> RoundView msg
view _ shared auth nextRoundReady config users round =
    let
        role =
            Player.role round auth.claims.uid

        stage =
            round.stage

        winning =
            stage.plays |> Dict.get stage.winner

        likeAction =
            let
                canBeLiked play =
                    Just play /= stage.likeDetail.played && not (Set.member play stage.likeDetail.liked)

                likeIfCanBeLiked pick =
                    Maybe.justIf (canBeLiked pick) Action.Like
            in
            case role of
                Player.RCzar ->
                    Nothing

                Player.RPlayer ->
                    stage.pick |> Maybe.andThen likeIfCanBeLiked

        msg _ =
            Nothing

        userAndPlay userId =
            let
                tuple : Play.Id -> Play.WithLikes -> ( User.Id, Play.Id, Play.WithLikes )
                tuple id p =
                    ( userId, id, p )

                play id =
                    Dict.get id stage.plays

                playId =
                    Dict.get userId stage.playedBy
            in
            Maybe.map2 tuple playId (playId |> Maybe.andThen play)
    in
    { instruction = Strings.AdvanceRoundInstruction |> Maybe.justIf nextRoundReady
    , action =
        Maybe.first
            [ Action.Advance |> Maybe.justIf nextRoundReady
            , likeAction
            ]
    , content =
        stage.playOrder
            |> List.filterMap userAndPlay
            |> List.map (details shared config stage.winner msg)
            |> Plays.view shared users [ ( "complete", True ) ] stage.likeDetail.liked stage.pick
    , slotAttrs = always []
    , fillCallWith = winning |> Maybe.map (.play >> Parts.fillsFromPlay) |> Maybe.withDefault Dict.empty
    , roundAttrs = []
    }


details : Shared -> Config -> User.Id -> (Play.Id -> Maybe msg) -> ( User.Id, Play.Id, Play.WithLikes ) -> Plays.Details msg
details shared config winner maybeMsg ( player, id, play ) =
    let
        cards =
            play.play |> List.map (\r -> Html.li [] [ Response.view shared config Card.Front [] r ])

        specialRole =
            if winner == player then
                Just Plays.Winner

            else
                Nothing

        byLine =
            Plays.ByLine player specialRole play.likes
    in
    Plays.Details id cards (id |> maybeMsg) (Just byLine)
