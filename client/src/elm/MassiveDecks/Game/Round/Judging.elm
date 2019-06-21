module MassiveDecks.Game.Round.Judging exposing (view)

import Html.Attributes as HtmlA
import MassiveDecks.Card as Card
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (..)
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
import Set exposing (Set)


view : Shared -> Auth -> List Configure.Deck -> Round.Judging -> RoundView Global.Msg
view shared auth decks round =
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
            round.plays |> List.map (playDetails shared decks round.liked)
    in
    { instruction = Just instruction
    , action = action
    , content = details |> Plays.view "judging" round.pick
    , fillCallWith = picked
    }



{- Private -}


playDetails : Shared -> List Configure.Deck -> Set Play.Id -> Play.Known -> Plays.Details Global.Msg
playDetails shared decks liked { id, responses } =
    let
        cards =
            responses
                |> List.map (\r -> Card.view shared decks Card.Front [] (Card.R r))

        attrs =
            [ HtmlA.class "liked" ] |> Maybe.justIf (Set.member id liked) |> Maybe.withDefault []
    in
    Plays.Details id cards (id |> PickPlay |> Lobby.GameMsg |> Global.LobbyMsg |> Just) attrs
