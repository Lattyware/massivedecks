module MassiveDecks.Game.Round.Complete exposing (view)

import Dict exposing (Dict)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Keyed as HtmlK
import MassiveDecks.Card.Model as Card
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
                |> List.map (\u -> ( u, Dict.get u round.plays |> Maybe.withDefault [] ))
                |> List.map (viewPlay shared config users round.winner)
            )
    , fillCallWith = winning |> Maybe.withDefault []
    }


viewPlay : Shared -> Config -> Dict User.Id User -> User.Id -> ( User.Id, List Card.Response ) -> ( String, Html msg )
viewPlay shared config users winner ( id, responses ) =
    let
        cards =
            responses |> List.map (\r -> ( r.details.id, Html.li [] [ Response.view config Card.Front [] r ] ))
    in
    ( id
    , Html.li [ HtmlA.class "with-byline" ]
        [ Plays.byLine shared users id (Icon.trophy |> Maybe.justIf (winner == id))
        , HtmlK.ol [ HtmlA.class "play card-set" ] cards
        ]
    )
