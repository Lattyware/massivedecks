module MassiveDecks.Game.History exposing (view)

import Dict exposing (Dict)
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Keyed as HtmlK
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play
import MassiveDecks.Card.Response as Response
import MassiveDecks.Game.Messages exposing (Msg(..))
import MassiveDecks.Game.Round as Round
import MassiveDecks.Game.Round.Plays as Plays
import MassiveDecks.Model exposing (Shared)
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Strings as Strings
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.NeList as NeList
import Material.IconButton as IconButton


view : (Msg -> msg) -> Shared -> Config -> Dict User.Id User -> String -> List (Round.Specific Round.Complete) -> List (Html msg)
view wrap shared config users name history =
    [ Html.div [ HtmlA.id "top-content" ]
        [ Html.div [ HtmlA.id "minor-actions" ]
            [ IconButton.view shared
                Strings.ViewGameHistoryAction
                (Icon.arrowLeft |> Icon.present |> NeList.just)
                (ToggleHistoryView |> wrap |> Just)
            ]
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


viewRound : Shared -> Config -> Dict User.Id User -> Round.Specific Round.Complete -> ( String, Html msg )
viewRound shared config users round =
    let
        winning =
            round.stage.plays |> Dict.get round.stage.winner

        winningBody =
            winning
                |> Maybe.map .play
                |> Maybe.map (List.indexedMap (\i v -> ( i, v.body )) >> Dict.fromList)
                |> Maybe.withDefault Dict.empty

        byLine =
            { by = round.czar, specialRole = Just Plays.Czar, likes = Nothing }
    in
    ( Round.idString round.id
    , Html.li [ HtmlA.class "historic-round" ]
        [ Html.div [ HtmlA.class "spacer" ]
            [ Html.div [ HtmlA.class "historic-call with-byline" ]
                [ Plays.viewByLine shared users byLine
                , Call.viewFilled shared config Card.Front [] (always []) winningBody round.call
                ]
            ]
        , HtmlK.ul [ HtmlA.class "plays cards" ]
            (round.stage.plays |> Dict.toList |> List.map (viewPlay shared config users round.stage.winner))
        ]
    )


viewPlay : Shared -> Config -> Dict User.Id User -> User.Id -> ( Play.Id, Play.WithDetails ) -> ( String, Html msg )
viewPlay shared config users winner ( id, { play, playedBy, likes } ) =
    let
        cards =
            play |> List.map (\r -> ( r.details.id, Html.li [] [ Response.view shared config Card.Front [] r ] ))
    in
    ( id
    , Html.li [ HtmlA.class "with-byline" ]
        [ Plays.viewByLine shared users (Plays.ByLine playedBy (Plays.Winner |> Maybe.justIf (winner == playedBy)) likes)
        , HtmlK.ol [ HtmlA.class "play card-set" ] cards
        ]
    )
