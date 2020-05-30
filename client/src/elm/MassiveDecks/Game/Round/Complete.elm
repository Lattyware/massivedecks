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
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Strings as Strings
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Maybe as Maybe


view : Shared -> Bool -> Config -> Dict User.Id User -> Round.Complete -> RoundView msg
view shared nextRoundReady config users round =
    let
        winning =
            round.plays |> Dict.get round.winner
    in
    { instruction = Strings.AdvanceRoundInstruction |> Maybe.justIf nextRoundReady
    , action = Action.Advance |> Maybe.justIf nextRoundReady
    , content =
        HtmlK.ul [ HtmlA.class "complete plays cards" ]
            (round.playOrder
                |> List.map (\u -> ( u, Dict.get u round.plays ))
                |> List.map (viewPlay shared config users round.winner)
            )
    , slotAttrs = always []
    , fillCallWith = winning |> Maybe.map (.play >> Parts.fillsFromPlay) |> Maybe.withDefault Dict.empty
    , roundAttrs = []
    }


viewPlay : Shared -> Config -> Dict User.Id User -> User.Id -> ( User.Id, Maybe Play.WithLikes ) -> ( String, Html msg )
viewPlay shared config users winner ( id, play ) =
    let
        cards =
            play
                |> Maybe.map (.play >> List.map (\r -> ( r.details.id, Html.li [] [ Response.view shared config Card.Front [] r ] )))
                |> Maybe.withDefault []
    in
    ( id
    , Html.li [ HtmlA.class "with-byline" ]
        [ Plays.byLine shared users id (( "trophy", Icon.trophy ) |> Maybe.justIf (winner == id)) (play |> Maybe.andThen .likes)
        , HtmlK.ol [ HtmlA.class "play card-set" ] cards
        ]
    )
