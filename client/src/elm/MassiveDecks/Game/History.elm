module MassiveDecks.Game.History exposing (view)

import Dict exposing (Dict)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html.Keyed as HtmlK
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Response as Response
import MassiveDecks.Components as Components
import MassiveDecks.Game.Messages exposing (Msg(..))
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Strings as Strings
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Maybe as Maybe


view : Shared -> Config -> Dict User.Id User -> String -> List Round.Complete -> List (Html Global.Msg)
view shared config users name history =
    [ Html.div [ HtmlA.id "minor-actions" ]
        [ Components.iconButton
            [ HtmlA.id "return-to-game-button"
            , Strings.ViewGameHistoryAction |> Lang.title shared
            , ToggleHistoryView |> lift |> HtmlE.onClick
            ]
            Icon.arrowLeft
        ]
    , Html.div [ HtmlA.id "history" ]
        [ Html.h2 [] [ Html.text name ]
        , HtmlK.ol
            [ HtmlA.class "historic-rounds"
            , HtmlA.reversed True
            , HtmlA.style "counter-reset"
                ("historic-round-number " ++ (history |> List.length |> (+) 1 |> String.fromInt))
            ]
            (history |> List.map (viewRound shared config users))
        ]
    ]



{- Private -}


viewRound : Shared -> Config -> Dict User.Id User -> Round.Complete -> ( String, Html msg )
viewRound shared config users round =
    let
        winning =
            round.plays |> Dict.get round.winner |> Maybe.withDefault [] |> List.map .body
    in
    ( Round.idString round.id
    , Html.li [ HtmlA.class "historic-round" ]
        [ Html.div [ HtmlA.class "historic-call with-byline" ]
            [ Plays.byLine shared users round.czar (Just Icon.gavel)
            , Html.div [] [ Call.viewFilled shared config Card.Front [] winning round.call ]
            ]
        , HtmlK.ul [ HtmlA.class "plays cards" ]
            (round.plays |> Dict.toList |> List.map (viewPlay shared config users round.winner))
        ]
    )


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


lift : Msg -> Global.Msg
lift msg =
    msg |> Lobby.GameMsg |> Global.LobbyMsg
