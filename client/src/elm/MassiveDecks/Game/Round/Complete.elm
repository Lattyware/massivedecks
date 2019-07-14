module MassiveDecks.Game.Round.Complete exposing (view)

import Dict exposing (Dict)
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Keyed as HtmlK
import MassiveDecks.Card as Card
import MassiveDecks.Card.Model as Card
import MassiveDecks.Game.Action.Model as Action
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Round as Round
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Configure.Model as Configure
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe


view : Shared -> Bool -> List Configure.Deck -> Dict User.Id User -> Round.Complete -> RoundView Global.Msg
view shared nextRoundReady decks users round =
    let
        winning =
            round.plays |> Dict.get round.winner
    in
    { instruction = Strings.AdvanceRoundInstruction |> Maybe.justIf nextRoundReady
    , action = Action.Advance |> Maybe.justIf nextRoundReady
    , content =
        HtmlK.ul [ HtmlA.class "complete plays cards" ]
            (round.plays |> Dict.toList |> List.map (viewPlay shared decks users round.winner))
    , fillCallWith = winning |> Maybe.withDefault []
    }


viewPlay :
    Shared
    -> List Configure.Deck
    -> Dict User.Id User
    -> User.Id
    -> ( User.Id, List Card.Response )
    -> ( String, Html Global.Msg )
viewPlay shared decks users winner ( id, responses ) =
    let
        cards =
            responses |> List.map (\r -> ( r.details.id, Card.view shared decks Card.Front [] (Card.R r) ))

        playedBy =
            users |> Dict.get id |> Maybe.map .name |> Maybe.withDefault (Strings.UnknownUser |> Lang.string shared)

        byline =
            [ Icon.view Icon.trophy |> Maybe.justIf (winner == id) |> Maybe.withDefault Html.nothing
            , Html.text playedBy
            ]
    in
    ( id
    , Html.li [ HtmlA.class "play-with-byline" ]
        [ Html.span [ HtmlA.class "byline" ] byline
        , HtmlK.ol [ HtmlA.class "play card-set" ] cards
        ]
    )
