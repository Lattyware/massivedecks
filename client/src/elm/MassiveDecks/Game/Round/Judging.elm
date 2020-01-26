module MassiveDecks.Game.Round.Judging exposing (view)

import Html.Attributes as HtmlA
import MassiveDecks.Card.Model as Card
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

        ( action, instruction ) =
            case role of
                Player.RCzar ->
                    ( Maybe.map (always Action.Judge) round.pick, Strings.RevealPlaysInstruction )

                Player.RPlayer ->
                    ( Maybe.andThen (\p -> Maybe.justIf (not (Set.member p round.liked)) Action.Like) round.pick, Strings.WaitingForCzarInstruction )

        picked =
            round.plays
                |> List.filter (\play -> Just play.id == round.pick)
                |> List.head
                |> Maybe.map .responses
                |> Maybe.withDefault []

        details =
            round.plays |> List.map (playDetails wrap shared config round.liked)
    in
    { instruction = Just instruction
    , action = action
    , content = details |> Plays.view "judging" round.pick
    , fillCallWith = picked
    }



{- Private -}


playDetails : (Msg -> msg) -> Shared -> Config -> Set Play.Id -> Play.Known -> Plays.Details msg
playDetails wrap shared config liked { id, responses } =
    let
        cards =
            responses
                |> List.map (\r -> Response.view shared config Card.Front [] r)

        attrs =
            [ HtmlA.class "liked" ] |> Maybe.justIf (Set.member id liked) |> Maybe.withDefault []
    in
    Plays.Details id cards (id |> PickPlay |> wrap |> Just) attrs
