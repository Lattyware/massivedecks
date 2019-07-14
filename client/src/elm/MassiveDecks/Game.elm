module MassiveDecks.Game exposing
    ( applyGameEvent
    , applyGameStarted
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Dom as Dom
import Dict exposing (Dict)
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card as Card
import MassiveDecks.Card.Model as Card
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Components as Components
import MassiveDecks.Game.Action as Action
import MassiveDecks.Game.Action.Model as Action exposing (Action)
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Player as Player exposing (Player)
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Game.Round.Complete as Complete
import MassiveDecks.Game.Round.Judging as Judging
import MassiveDecks.Game.Round.Playing as Playing
import MassiveDecks.Game.Round.Revealing as Revealing
import MassiveDecks.Messages as Global
import MassiveDecks.Model exposing (..)
import MassiveDecks.Pages.Lobby.Actions as Actions
import MassiveDecks.Pages.Lobby.Configure.Model as Configure
import MassiveDecks.Pages.Lobby.Events as Events
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Lobby)
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util as Util
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import Set
import Task
import Weightless as Wl
import Weightless.Attributes as WlA


init : Game -> List Card.Response -> Round.Pick -> ( Model, Cmd Global.Msg )
init game hand pick =
    let
        model =
            emptyModel game

        ( round, cmd ) =
            case game.round of
                Round.P r ->
                    Util.modelLift Round.P (Playing.init r pick)

                _ ->
                    ( game.round, Cmd.none )
    in
    ( { model | hand = hand, game = { game | round = round } }, cmd )


update : Msg -> Model -> ( Model, Cmd Global.Msg )
update msg model =
    let
        game =
            model.game
    in
    case msg of
        Pick id ->
            case game.round of
                Round.P playingRound ->
                    let
                        picks =
                            playingRound.pick

                        picked =
                            if List.member id picks.cards then
                                List.filter ((/=) id) picks.cards

                            else
                                picks.cards ++ [ id ]

                        extra =
                            max 0 (List.length picked - (playingRound.call |> Card.slotCount))

                        newRound =
                            Round.P { playingRound | pick = { picks | cards = picked |> List.drop extra } }
                    in
                    ( { model | game = { game | round = newRound } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PickPlay id ->
            let
                newRound =
                    case game.round of
                        Round.J judging ->
                            { judging | pick = Just id } |> Round.J

                        _ ->
                            game.round
            in
            ( { model | game = { game | round = newRound } }, Cmd.none )

        Submit ->
            case game.round of
                Round.P playingRound ->
                    let
                        picks =
                            playingRound.pick

                        newRound =
                            Round.P { playingRound | pick = { picks | state = Round.Submitted } }
                    in
                    ( { model | game = { game | round = newRound } }, Actions.submit picks.cards )

                _ ->
                    ( model, Cmd.none )

        TakeBack ->
            case game.round of
                Round.P playingRound ->
                    let
                        picks =
                            playingRound.pick

                        newRound =
                            Round.P { playingRound | pick = { picks | state = Round.Selected } }
                    in
                    ( { model | game = { game | round = newRound } }, Actions.takeBack )

                _ ->
                    ( model, Cmd.none )

        ScrollToTop ->
            ( model, Dom.setViewportOf "scroll-frame" 0 0 |> Task.attempt (\_ -> Global.NoOp) )

        Reveal play ->
            ( model, Actions.reveal play )

        Judge ->
            let
                cmd =
                    case game.round of
                        Round.J judging ->
                            judging.pick |> Maybe.map Actions.judge |> Maybe.withDefault Cmd.none

                        _ ->
                            Cmd.none
            in
            ( model, cmd )

        Like ->
            -- TODO: Actually sending this somewhere.
            let
                newRound =
                    case game.round of
                        Round.J judging ->
                            { judging
                                | liked =
                                    judging.pick
                                        |> Maybe.map (\p -> Set.insert p judging.liked)
                                        |> Maybe.withDefault judging.liked
                            }
                                |> Round.J

                        _ ->
                            game.round
            in
            ( { model | game = { game | round = newRound } }, Cmd.none )

        SetPlayStyles playStyles ->
            ( { model | playStyles = playStyles }, Cmd.none )

        AdvanceRound ->
            case model.nextRound of
                Just nextRound ->
                    ( { model | game = { game | round = Round.P nextRound }, nextRound = Nothing }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Global.Msg
subscriptions model =
    Sub.none


view : Shared -> Lobby.Auth -> List Configure.Deck -> Dict User.Id User -> Model -> Html Global.Msg
view shared auth decks users model =
    let
        { instruction, action, content, fillCallWith } =
            case game.round of
                Round.P round ->
                    Playing.view shared auth decks model round

                Round.R round ->
                    Revealing.view shared auth decks round

                Round.J round ->
                    Judging.view shared auth decks round

                Round.C round ->
                    Complete.view shared (Maybe.isJust model.nextRound) decks users round

        game =
            model.game

        { call } =
            Round.data game.round

        parts =
            fillCallWith |> List.map .body

        renderedCall =
            call |> Card.viewFilled shared decks Card.Front [] parts

        help =
            let
                id =
                    "context-help-button"

                helpContent =
                    case instruction of
                        Just i ->
                            [ Components.iconButton
                                [ HtmlA.id id, Strings.WhatToDo |> Lang.title shared ]
                                Icon.question
                            , Wl.popover
                                (List.concat
                                    [ WlA.anchorOrigin WlA.XCenter WlA.YBottom
                                    , WlA.transformOrigin WlA.XRight WlA.YTop
                                    , [ WlA.anchor id, WlA.fixed, WlA.anchorOpenEvents [ "click" ] ]
                                    ]
                                )
                                [ Wl.popoverCard [] [ i |> Lang.html shared ] ]
                            ]

                        Nothing ->
                            []
            in
            Html.div [ HtmlA.id "context-help" ] helpContent
    in
    Html.div [ HtmlA.id "game" ]
        [ help
        , Html.div [ HtmlA.class "round" ]
            [ renderedCall
            , viewAction shared action
            ]
        , content
        , Html.div [ HtmlA.class "scroll-top-spacer" ] []

        -- TODO: Hide this when at top. Waiting on native elm scroll events, as currently we'd have to ping constantly.
        , Html.div [ HtmlA.class "scroll-top" ]
            [ Wl.button
                [ WlA.flat
                , WlA.fab
                , WlA.inverted
                , ScrollToTop |> lift |> HtmlE.onClick
                ]
                [ Icon.view Icon.arrowUp ]
            ]
        ]


viewAction : Shared -> Maybe Action -> Html Global.Msg
viewAction shared visible =
    Html.div [] (Action.actions |> List.map (Action.view shared visible))


applyGameEvent : Lobby.Auth -> Events.GameEvent -> Model -> ( Model, Cmd Global.Msg )
applyGameEvent auth gameEvent model =
    case gameEvent of
        Events.HandRedrawn { player, hand } ->
            let
                game =
                    model.game

                -- TODO: Error, if the rule isn't enabled, we are out of sync.
                cost =
                    game.rules.houseRules.reboot |> Maybe.map .cost |> Maybe.withDefault 0

                updatePlayer =
                    \id -> \p -> { p | score = p.score - cost } |> Maybe.justIf (player == id) |> Maybe.withDefault p

                -- TODO: Error, if we get a hand but the event claims another player, we are out of sync.
                newHand =
                    hand |> Maybe.andThen (Maybe.justIf (player == auth.claims.uid)) |> Maybe.withDefault model.hand

                players =
                    game.players |> Dict.map updatePlayer
            in
            ( { model | game = { game | players = players }, hand = newHand }, Cmd.none )

        Events.PlayRevealed { id, play } ->
            let
                game =
                    model.game

                newRound =
                    case model.game.round of
                        Round.R r ->
                            let
                                plays =
                                    r.plays |> List.map (reveal id play)

                                known =
                                    plays |> List.filterMap Play.asKnown
                            in
                            if List.length known == List.length plays then
                                Round.judging r.id r.czar r.players r.call known |> Round.J

                            else
                                { r | plays = plays } |> Round.R

                        _ ->
                            -- TODO: Error
                            model.game.round
            in
            ( { model | game = { game | round = newRound } }, Cmd.none )

        Events.PlaySubmitted { by } ->
            case model.game.round of
                Round.P round ->
                    let
                        game =
                            model.game
                    in
                    ( { model | game = { game | round = Round.P { round | played = Set.insert by round.played } } }
                    , Cmd.none
                    )

                _ ->
                    -- TODO: Error
                    ( model, Cmd.none )

        Events.PlayTakenBack { by } ->
            case model.game.round of
                Round.P round ->
                    let
                        game =
                            model.game
                    in
                    ( { model | game = { game | round = Round.P { round | played = Set.remove by round.played } } }
                    , Cmd.none
                    )

                _ ->
                    -- TODO: Error
                    ( model, Cmd.none )

        Events.RoundFinished { winner, playedBy } ->
            let
                game =
                    model.game

                newPlayers =
                    game.players |> Dict.update winner (Maybe.map (\p -> { p | score = p.score + 1 }))

                newRound =
                    case model.game.round of
                        Round.J r ->
                            let
                                plays =
                                    r.plays |> List.filterMap (resolvePlayedBy playedBy) |> Dict.fromList
                            in
                            Round.complete r.id r.czar r.players r.call plays winner |> Round.C

                        _ ->
                            -- TODO: Error
                            model.game.round
            in
            ( { model | game = { game | round = newRound, players = newPlayers } }, Cmd.none )

        Events.RoundStarted { id, czar, players, call, drawn } ->
            let
                drawnAsList =
                    drawn |> Maybe.withDefault []

                ( newRound, cmd ) =
                    Playing.init (Round.playing id czar players call Set.empty) Round.noPick
            in
            ( { model | nextRound = Just newRound, hand = model.hand ++ drawnAsList }, cmd )

        Events.StartRevealing { plays, drawn } ->
            case model.game.round of
                Round.P r ->
                    let
                        oldGame =
                            model.game

                        newRound =
                            Round.revealing
                                r.id
                                r.czar
                                r.players
                                r.call
                                (plays |> List.map (\id -> Play id Nothing))
                                |> Round.R

                        newHand =
                            model.hand
                                |> List.filter (\c -> not (List.member c.details.id r.pick.cards))
                                |> (\h -> h ++ (drawn |> Maybe.withDefault []))
                    in
                    ( { model | game = { oldGame | round = newRound }, hand = newHand }, Cmd.none )

                _ ->
                    -- TODO: Error
                    ( model, Cmd.none )


applyGameStarted : Lobby -> Round.Playing -> List Card.Response -> ( Model, Cmd Global.Msg )
applyGameStarted lobby round hand =
    let
        users =
            lobby.users |> Dict.toList |> List.map (\( id, _ ) -> id)

        defaultPlayer =
            { control = Player.Human, score = 0 }

        game =
            { round = Round.P round
            , history = []
            , playerOrder = users
            , players =
                users
                    |> List.map (\id -> ( id, defaultPlayer ))
                    |> Dict.fromList
            , rules = lobby.config.rules
            , winner = Nothing
            }
    in
    init game hand Round.noPick



{- Private -}


reveal : Play.Id -> List Card.Response -> Play -> Play
reveal target responses play =
    case play.responses of
        Nothing ->
            if play.id == target then
                Play play.id (Just responses)

            else
                play

        _ ->
            play


resolvePlayedBy : Dict Play.Id User.Id -> Play.Known -> Maybe ( User.Id, List Card.Response )
resolvePlayedBy playedBy k =
    Dict.get k.id playedBy |> Maybe.map (\u -> ( u, k.responses ))


type alias ActionDetails msg =
    { content : List (Html msg)
    , title : MdString
    }


type alias RoundDetails msg =
    { instruction : MdString
    , callback : List (Html.Attribute msg)
    , picks : List Card.Id
    , callFlipped : Bool
    , playing : Bool
    }


lift : Msg -> Global.Msg
lift msg =
    msg |> Lobby.GameMsg |> Global.LobbyMsg
