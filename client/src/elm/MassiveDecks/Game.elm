module MassiveDecks.Game exposing
    ( applyGameEvent
    , applyGameStarted
    , hotJoinPlayer
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Dom as Dom
import Browser.Events as Browser
import Dict exposing (Dict)
import FontAwesome.Attributes as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Html5.DragDrop as DragDrop
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card exposing (Call)
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Play as Play exposing (Play)
import MassiveDecks.Card.Response as Response
import MassiveDecks.Card.Source.Model as Source
import MassiveDecks.Components as Components
import MassiveDecks.Game.Action as Action
import MassiveDecks.Game.Action.Model exposing (Action)
import MassiveDecks.Game.History as History
import MassiveDecks.Game.Messages exposing (..)
import MassiveDecks.Game.Model exposing (..)
import MassiveDecks.Game.Player as Player exposing (Player)
import MassiveDecks.Game.Round as Round exposing (Round)
import MassiveDecks.Game.Round.Complete as Complete
import MassiveDecks.Game.Round.Judging as Judging
import MassiveDecks.Game.Round.Playing as Playing
import MassiveDecks.Game.Round.Revealing as Revealing
import MassiveDecks.Game.Rules as Rules
import MassiveDecks.Game.Time as Time exposing (Time)
import MassiveDecks.Model exposing (..)
import MassiveDecks.Notifications as Notifications
import MassiveDecks.Pages.Lobby.Actions as Actions
import MassiveDecks.Pages.Lobby.Configure.Model exposing (Config)
import MassiveDecks.Pages.Lobby.Events as Events exposing (Event)
import MassiveDecks.Pages.Lobby.Messages as Lobby
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Lobby)
import MassiveDecks.Pages.Lobby.Route as Lobby
import MassiveDecks.Ports as Ports
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Html.Events as HtmlE
import MassiveDecks.Util.Maybe as Maybe
import MassiveDecks.Util.NeList as NeList
import Material.Button as Button
import Material.Card as Card
import Material.IconButton as IconButton
import Material.LinearProgress as LinearProgress
import Set exposing (Set)
import Task


init : (Msg -> msg) -> Game -> List Card.Response -> Round.Pick -> ( Model, Cmd msg )
init wrap game hand pick =
    let
        model =
            emptyModel game

        ( round, roundCmd ) =
            case game.round of
                Round.P r ->
                    let
                        ( playing, cmd ) =
                            Playing.init wrap r pick
                    in
                    ( Round.P playing, cmd )

                _ ->
                    ( game.round, Cmd.none )

        timeCmd =
            Time.now (UpdateTimer >> wrap)
    in
    ( { model | hand = hand, game = { game | round = round } }, Cmd.batch [ roundCmd, timeCmd ] )


update : (Msg -> msg) -> Shared -> Msg -> Model -> ( Model, Cmd msg )
update wrap shared msg model =
    let
        game =
            model.game
    in
    case msg of
        Pick maybeFor played ->
            case game.round of
                Round.P playingRound ->
                    let
                        picks =
                            playingRound.pick

                        picked =
                            case maybeFor of
                                Just for ->
                                    picks.cards |> Dict.insert for played

                                Nothing ->
                                    if picks.cards |> Dict.values |> List.member played then
                                        picks.cards |> Dict.filter (\_ p -> p /= played)

                                    else
                                        let
                                            missing =
                                                Parts.missingSlotIndices picks.cards playingRound.call.body |> Set.toList
                                        in
                                        case missing of
                                            next :: _ ->
                                                picks.cards |> Dict.insert next played

                                            [] ->
                                                let
                                                    last =
                                                        picks.cards |> Dict.keys |> List.maximum |> Maybe.withDefault 0
                                                in
                                                picks.cards |> Dict.insert last played

                        newRound =
                            Round.P { playingRound | pick = { picks | cards = picked } }

                        focus =
                            Dom.focus played
                                |> Task.onError (\_ -> Task.succeed ())
                                |> Task.perform (\_ -> wrap NoOp)
                    in
                    ( { model | game = { game | round = newRound } }, focus )

                _ ->
                    ( model, Cmd.none )

        Unpick slotId ->
            case game.round of
                Round.P playingRound ->
                    let
                        picks =
                            playingRound.pick

                        picked =
                            picks.cards |> Dict.remove slotId

                        newRound =
                            Round.P { playingRound | pick = { picks | cards = picked } }
                    in
                    ( { model | game = { game | round = newRound } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Drag dragDropMsg ->
            let
                ( dragDrop, result ) =
                    DragDrop.update dragDropMsg model.dragDrop

                newRound =
                    case game.round of
                        Round.P playingRound ->
                            let
                                picks =
                                    playingRound.pick

                                picked =
                                    case result of
                                        Just ( card, slotIndex, _ ) ->
                                            picks.cards
                                                |> Dict.filter (\_ p -> p /= card)
                                                |> Dict.insert slotIndex card

                                        Nothing ->
                                            picks.cards
                            in
                            Round.P { playingRound | pick = { picks | cards = picked } }

                        _ ->
                            game.round
            in
            ( { model | game = { game | round = newRound }, dragDrop = dragDrop }, Cmd.none )

        EditBlank id text ->
            case game.round of
                Round.P playingRound ->
                    if playingRound.pick.state /= Round.Submitted then
                        ( { model | filledCards = model.filledCards |> Dict.insert id text }, Cmd.none )

                    else
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Fill id text ->
            let
                changed response =
                    response.details.id == id && response.body /= text
            in
            if List.any changed model.hand then
                let
                    updateCard response =
                        if response.details.id == id then
                            { response | body = text }

                        else
                            response
                in
                ( { model | hand = model.hand |> List.map updateCard }, Actions.fill id text )

            else
                ( model, Cmd.none )

        PickPlay id ->
            let
                makePick r wrapRound =
                    let
                        pick =
                            if r.pick == Just id then
                                Nothing

                            else
                                Just id
                    in
                    { r | pick = pick } |> wrapRound

                newRound =
                    case game.round of
                        Round.J judging ->
                            makePick judging Round.J

                        Round.R revealing ->
                            makePick revealing Round.R

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

                        fillIfNeeded card =
                            if card.details.source == Source.Custom then
                                let
                                    id =
                                        card.details.id
                                in
                                if picks.cards |> Dict.values |> List.member id then
                                    let
                                        value =
                                            Dict.get id model.filledCards |> Maybe.withDefault ""
                                    in
                                    if value /= card.body then
                                        Just (Actions.fill id value)

                                    else
                                        Nothing

                                else
                                    Nothing

                            else
                                Nothing

                        fills =
                            model.hand |> List.filterMap fillIfNeeded

                        newRound =
                            Round.P { playingRound | pick = { picks | state = Round.Submitted } }
                    in
                    ( { model | game = { game | round = newRound } }
                    , Cmd.batch (fills ++ [ picks.cards |> Dict.values |> Actions.submit ])
                    )

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
            ( model, Dom.setViewportOf "scroll-frame" 0 0 |> Task.attempt (NoOp |> wrap |> always) )

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
            let
                ( newRound, action ) =
                    let
                        like r roundWrap =
                            let
                                likeDetail =
                                    r.likeDetail

                                insert =
                                    r.pick
                                        |> Maybe.map Set.insert
                                        |> Maybe.withDefault identity

                                newLikeDetail =
                                    { likeDetail | liked = insert likeDetail.liked }
                            in
                            ( { r | pick = Nothing, likeDetail = newLikeDetail } |> roundWrap
                            , r.pick |> Maybe.map Actions.like |> Maybe.withDefault Cmd.none
                            )
                    in
                    case game.round of
                        Round.J judging ->
                            like judging Round.J

                        Round.R revealing ->
                            like revealing Round.R

                        _ ->
                            ( game.round, Cmd.none )
            in
            ( { model | game = { game | round = newRound } }, action )

        SetPlayStyles playStyles ->
            ( { model | playStyles = playStyles }, Cmd.none )

        AdvanceRound ->
            case model.completeRound of
                Just _ ->
                    let
                        round =
                            model.game.round

                        tts =
                            speak shared (round |> Round.data |> .call) Nothing
                    in
                    ( { model | completeRound = Nothing }
                    , tts
                    )

                Nothing ->
                    ( model, Cmd.none )

        Redraw ->
            ( model, Actions.redraw )

        Discard ->
            case model.game.round of
                Round.P p ->
                    let
                        action =
                            p.pick.cards |> Dict.values |> List.head |> Maybe.map Actions.discard
                    in
                    ( model, action |> Maybe.withDefault Cmd.none )

                _ ->
                    ( model, Cmd.none )

        DismissDiscard ->
            let
                discarded =
                    model.discarded |> List.tail |> Maybe.withDefault []
            in
            ( { model | discarded = discarded }, Cmd.none )

        ToggleHistoryView ->
            ( { model | viewingHistory = not model.viewingHistory }, Cmd.none )

        SetPresence presence ->
            ( model, Actions.setPresence presence )

        SetPlayerAway player ->
            ( model, Actions.setPlayerAway player )

        UpdateTimer time ->
            ( { model | time = Just time }, Cmd.none )

        EnforceTimeLimit ->
            ( model, Actions.enforceTimeLimit (model.game.round |> Round.data |> .id) (model.game.round |> Round.stage) )

        ToggleHelp ->
            ( { model | helpVisible = not model.helpVisible }, Cmd.none )

        Confetti ->
            ( { model | confetti = True }, Ports.startConfetti confettiId )

        NoOp ->
            ( model, Cmd.none )


subscriptions : (Msg -> msg) -> Time.Anchor -> Model -> Sub msg
subscriptions wrap anchor model =
    let
        ( startedAt, maybeLimitSeconds, timedOut ) =
            roundTimeDetails model.game

        timerSub =
            if timedOut || model.game.winner /= Nothing then
                Sub.none

            else
                case maybeLimitSeconds of
                    Nothing ->
                        Sub.none

                    Just limitSeconds ->
                        case model.time of
                            Just time ->
                                let
                                    left =
                                        timeLeft anchor startedAt time limitSeconds
                                in
                                if left < 0 then
                                    Sub.none

                                else if left > showProgressBarForLast then
                                    Time.every 500 (UpdateTimer >> wrap)

                                else
                                    Time.animate (UpdateTimer >> wrap)

                            Nothing ->
                                Time.animate (UpdateTimer >> wrap)

        confettiSub =
            if model.game.winner /= Nothing && not model.confetti then
                Browser.onAnimationFrame (Confetti |> wrap |> always)

            else
                Sub.none
    in
    Sub.batch [ timerSub, confettiSub ]


view : (Lobby.Msg -> msg) -> (Msg -> msg) -> Shared -> Lobby.Auth -> Time.Anchor -> String -> Config -> Dict User.Id User -> Model -> Html msg
view wrapLobby wrap shared auth timeAnchor name config users model =
    let
        overlay =
            if model.game.players |> Dict.get auth.claims.uid |> Maybe.map (\p -> p.presence == Player.Away) |> Maybe.withDefault False then
                gameOverlay shared Strings.ClientAway (Just ( Strings.SetBack, Player.Active |> SetPresence |> wrap ))

            else if model.game.paused then
                gameOverlay shared Strings.Paused Nothing

            else
                []

        gameView =
            if model.viewingHistory then
                History.view wrap shared config users name model.game.history

            else
                case model.game.winner of
                    Just winners ->
                        viewWinner wrapLobby shared users auth.claims.uid winners

                    Nothing ->
                        viewRound wrap shared auth timeAnchor config users model
    in
    Html.div [ HtmlA.id "game" ] (overlay ++ gameView)


applyGameEvent : (Msg -> msg) -> (Event -> msg) -> Lobby.Auth -> Shared -> Events.GameEvent -> Model -> ( Model, Cmd msg )
applyGameEvent wrap wrapEvent auth shared gameEvent model =
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

                newRound =
                    if player == auth.claims.uid then
                        case game.round of
                            Round.P playing ->
                                let
                                    pick =
                                        playing.pick
                                in
                                Round.P { playing | pick = { pick | cards = Dict.empty } }

                            other ->
                                other

                    else
                        game.round

                players =
                    game.players |> Dict.map updatePlayer
            in
            ( { model | game = { game | players = players, round = newRound }, hand = newHand }, Cmd.none )

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

        Events.Timed (Events.NoTime { event }) ->
            ( model
            , Time.now
                (\time ->
                    Events.WithTime { event = event, time = time }
                        |> Events.Timed
                        |> Events.Game
                        |> wrapEvent
                )
            )

        Events.Timed (Events.WithTime { event, time }) ->
            case event of
                Events.StartRevealing { plays, afterPlaying } ->
                    case model.game.round of
                        Round.P r ->
                            let
                                { played, drawn } =
                                    afterPlaying

                                oldGame =
                                    model.game

                                newRound =
                                    Round.revealing
                                        (Just { played = played, liked = Set.empty })
                                        r.id
                                        r.czar
                                        r.players
                                        r.call
                                        (plays |> List.map (\id -> Play id Nothing))
                                        time
                                        False
                                        |> Round.R

                                picked =
                                    r.pick.cards |> Dict.values |> Set.fromList

                                newHand =
                                    model.hand
                                        |> List.filter (\c -> not (Set.member c.details.id picked))
                                        |> (\h -> h ++ (drawn |> Maybe.withDefault []))

                                role =
                                    Player.role newRound auth.claims.uid

                                notification =
                                    if role == Player.RCzar then
                                        Notifications.notify shared
                                            { title = Strings.JudgingStarted
                                            , body = Strings.RevealPlaysInstruction
                                            }

                                    else
                                        Cmd.none
                            in
                            ( { model | game = { oldGame | round = newRound }, hand = newHand }, notification )

                        _ ->
                            -- TODO: Error
                            ( model, Cmd.none )

                Events.RoundFinished { winner, playedBy } ->
                    let
                        game =
                            model.game

                        playersWithWinner =
                            game.players |> Dict.update winner (Maybe.map (\p -> { p | score = p.score + 1 }))

                        { newRound, history, speech, newPlayers, filledCards } =
                            case game.round of
                                Round.J r ->
                                    let
                                        plays =
                                            r.plays |> List.filterMap (resolvePlayedBy playedBy)

                                        playsDict =
                                            plays |> Dict.fromList

                                        complete =
                                            Round.complete
                                                r.id
                                                r.czar
                                                r.players
                                                r.call
                                                playsDict
                                                (plays |> List.map (\( u, _ ) -> u))
                                                winner
                                                time

                                        handIds =
                                            model.hand |> List.map (.details >> .id) |> Set.fromList

                                        isStillInHand id _ =
                                            Set.member id handIds

                                        tts =
                                            Dict.get winner playsDict
                                                |> Maybe.map (\p -> speak shared r.call (p.play |> Parts.fillsFromPlay |> Just))
                                                |> Maybe.withDefault Cmd.none

                                        ps =
                                            playersWithWinner |> Dict.map (updateLikes playsDict)
                                    in
                                    { newRound = complete |> Round.C
                                    , history = complete :: game.history
                                    , speech = tts
                                    , newPlayers = ps
                                    , filledCards = model.filledCards |> Dict.filter isStillInHand
                                    }

                                _ ->
                                    -- TODO: Error
                                    { newRound = game.round
                                    , history = game.history
                                    , speech = Cmd.none
                                    , newPlayers = playersWithWinner
                                    , filledCards = model.filledCards
                                    }
                    in
                    ( { model
                        | game =
                            { game
                                | round = newRound
                                , players = newPlayers
                                , history = history
                            }
                        , filledCards = filledCards
                      }
                    , speech
                    )

                Events.RoundStarted { id, czar, players, call, drawn } ->
                    let
                        game =
                            model.game

                        drawnAsList =
                            drawn |> Maybe.withDefault []

                        ( newRound, cmd ) =
                            Playing.init wrap (Round.playing id czar players call Set.empty time False) Round.noPick

                        notification =
                            if Set.member auth.claims.uid players then
                                Notifications.notify shared
                                    { title = Strings.RoundStarted
                                    , body = Strings.PlayInstruction { numberOfCards = Call.slotCount call }
                                    }

                            else
                                Cmd.none

                        completeRound =
                            if shared.settings.settings.autoAdvance |> Maybe.withDefault False then
                                Nothing

                            else
                                case model.game.round of
                                    Round.C c ->
                                        Just c

                                    _ ->
                                        Nothing
                    in
                    ( { model
                        | game = { game | round = Round.P newRound }
                        , completeRound = completeRound
                        , hand = model.hand ++ drawnAsList
                      }
                    , Cmd.batch [ cmd, notification ]
                    )

                Events.PlayRevealed { id, play } ->
                    let
                        game =
                            model.game

                        ( newRound, speech ) =
                            case model.game.round of
                                Round.R r ->
                                    let
                                        plays =
                                            r.plays |> List.map (reveal id play)

                                        round =
                                            { r | plays = plays, lastRevealed = Just id } |> Round.R

                                        tts =
                                            speak shared r.call (play |> Parts.fillsFromPlay |> Just)
                                    in
                                    ( round, tts )

                                _ ->
                                    -- TODO: Error
                                    ( model.game.round, Cmd.none )
                    in
                    ( { model | game = { game | round = newRound } }, speech )

                Events.StartJudging { plays, afterPlaying } ->
                    let
                        { played, drawn } =
                            afterPlaying

                        game =
                            model.game

                        makeNewRound r pick ld known =
                            case known of
                                Just k ->
                                    Round.judging pick
                                        ld
                                        r.id
                                        r.czar
                                        r.players
                                        r.call
                                        k
                                        time
                                        False
                                        |> Round.J

                                Nothing ->
                                    -- TODO: Error.
                                    game.round

                        ( newRound, newHand ) =
                            case game.round of
                                Round.P r ->
                                    let
                                        picked =
                                            r.pick.cards |> Dict.values |> Set.fromList

                                        nH =
                                            model.hand
                                                |> List.filter (\c -> not (Set.member c.details.id picked))
                                                |> (\h -> h ++ (drawn |> Maybe.withDefault []))
                                    in
                                    ( makeNewRound r Nothing (Just { played = played, liked = Set.empty }) plays
                                    , nH
                                    )

                                Round.R r ->
                                    let
                                        p =
                                            plays
                                                |> Maybe.withDefault (r.plays |> List.filterMap Play.asKnown)
                                                |> Just
                                    in
                                    ( makeNewRound r r.pick (Just r.likeDetail) p, model.hand )

                                _ ->
                                    -- TODO: Error.
                                    ( game.round, model.hand )
                    in
                    ( { model | game = { game | round = newRound }, hand = newHand }, Cmd.none )

        Events.PlayerAway { player } ->
            let
                game =
                    model.game

                players =
                    game.players |> Dict.map (setPresence player Player.Away)
            in
            ( { model | game = { game | players = players } }, Cmd.none )

        Events.PlayerBack { player } ->
            let
                game =
                    model.game

                players =
                    game.players |> Dict.map (setPresence player Player.Active)
            in
            ( { model | game = { game | players = players } }, Cmd.none )

        Events.Paused ->
            let
                game =
                    model.game
            in
            ( { model | game = { game | paused = True } }, Cmd.none )

        Events.Continued ->
            let
                game =
                    model.game
            in
            ( { model | game = { game | paused = False } }, Cmd.none )

        Events.StageTimerDone { round, stage } ->
            let
                game =
                    model.game
            in
            if (game.round |> Round.data |> .id) == round && Round.stage game.round == stage then
                let
                    newRound =
                        case game.round of
                            Round.P playing ->
                                Round.P { playing | timedOut = True }

                            Round.R revealing ->
                                Round.R { revealing | timedOut = True }

                            Round.J judging ->
                                Round.J { judging | timedOut = True }

                            Round.C complete ->
                                Round.C complete
                in
                ( { model | game = { game | round = newRound } }, Cmd.none )

            else
                ( model, Cmd.none )

        Events.GameEnded { winner } ->
            let
                game =
                    model.game
            in
            ( { model | game = { game | winner = Just winner }, confetti = False }, Cmd.none )

        Events.CardDiscarded { player, card, replacement } ->
            let
                game =
                    model.game

                ( hand, round, discarded ) =
                    case replacement of
                        Just replacementCard ->
                            let
                                replace c =
                                    if c.details.id == card.details.id then
                                        replacementCard

                                    else
                                        c

                                r =
                                    game.round

                                newRound =
                                    case r of
                                        Round.P playing ->
                                            let
                                                pick =
                                                    playing.pick

                                                notDiscarded _ id =
                                                    id /= card.details.id

                                                newPick =
                                                    { pick | cards = pick.cards |> Dict.filter notDiscarded }
                                            in
                                            Round.P { playing | pick = newPick }

                                        other ->
                                            other
                            in
                            ( model.hand |> List.map replace, newRound, model.discarded )

                        Nothing ->
                            ( model.hand, game.round, model.discarded ++ [ ( player, card ) ] )
            in
            ( { model | hand = hand, discarded = discarded, game = { game | round = round } }, Cmd.none )


applyGameStarted : (Msg -> msg) -> Lobby -> Round.Playing -> List Card.Response -> ( Model, Cmd msg )
applyGameStarted wrap lobby round hand =
    let
        users =
            lobby.users |> Dict.toList |> List.map (\( id, _ ) -> id)

        game =
            { round = Round.P round
            , history = []
            , playerOrder = users
            , players =
                users
                    |> List.map (\id -> ( id, Player.default ))
                    |> Dict.fromList
            , rules = lobby.config.rules
            , winner = Nothing
            , paused = False
            }
    in
    init wrap game hand Round.noPick


hotJoinPlayer : User.Id -> User -> Model -> Model
hotJoinPlayer player user model =
    let
        oldGame =
            model.game

        players =
            case user.role of
                User.Player ->
                    oldGame.players |> Dict.insert player Player.default

                User.Spectator ->
                    oldGame.players

        game =
            { oldGame
                | players = players
                , playerOrder = oldGame.playerOrder ++ [ player ]
            }
    in
    { model | game = game }



{- Private -}


updateLikes : Dict User.Id Play.WithLikes -> User.Id -> Player -> Player
updateLikes plays uid player =
    plays
        |> Dict.get uid
        |> Maybe.andThen .likes
        |> Maybe.map (\likes -> { player | likes = likes + player.likes })
        |> Maybe.withDefault player


confettiId : String
confettiId =
    "win-confetti-overlay"


viewWinner : (Lobby.Msg -> msg) -> Shared -> Dict User.Id User -> User.Id -> Set User.Id -> List (Html msg)
viewWinner wrapLobby shared users localUser winners =
    let
        configureNextGame =
            if users |> Dict.get localUser |> Maybe.map (.privilege >> (==) User.Privileged) |> Maybe.withDefault False then
                Button.view shared
                    Button.Raised
                    Strings.ConfigureNextGame
                    Strings.ConfigureNextGame
                    (Icon.cog |> Icon.viewIcon)
                    [ HtmlA.id "new-game-config"
                    , Lobby.Configure |> Just |> Lobby.ChangeSection |> wrapLobby |> HtmlE.onClick
                    ]

            else
                Html.nothing
    in
    [ Card.view [ HtmlA.id "game-winner" ]
        [ Html.span [] [ Icon.trophy |> Icon.viewIcon ]
        , Html.ul [] (winners |> Set.toList |> List.map (viewWinnerListItem shared users))
        ]
    , configureNextGame
    , Html.canvas [ HtmlA.id confettiId ] []
    ]


viewWinnerListItem : Shared -> Dict User.Id User -> User.Id -> Html msg
viewWinnerListItem shared users user =
    Html.li []
        [ users
            |> Dict.get user
            |> Maybe.map .name
            |> Maybe.withDefault (Strings.UnknownUser |> Lang.string shared)
            |> Html.text
        ]


viewRound : (Msg -> msg) -> Shared -> Lobby.Auth -> Time.Anchor -> Config -> Dict User.Id User -> Model -> List (Html msg)
viewRound wrap shared auth timeAnchor config users model =
    let
        ( call, { instruction, action, content, slotAttrs, fillCallWith, roundAttrs } ) =
            case model.completeRound of
                Just completeRound ->
                    ( completeRound.call, Complete.view shared True config users completeRound )

                Nothing ->
                    case game.round of
                        Round.P round ->
                            ( round.call, Playing.view wrap auth shared config users model round )

                        Round.R round ->
                            ( round.call, Revealing.view wrap auth shared config round )

                        Round.J round ->
                            ( round.call, Judging.view wrap auth shared config round )

                        Round.C round ->
                            ( round.call, Complete.view shared False config users round )

        game =
            model.game

        renderedCall =
            call |> Call.viewFilled shared config Card.Front [] slotAttrs fillCallWith
    in
    [ Html.div [ HtmlA.id "top-content" ]
        [ case instruction |> Maybe.andThen (Maybe.justIf model.helpVisible) of
            Just i ->
                Card.view [ HtmlA.class "help" ] [ Icon.questionCircle |> Icon.viewIcon, i |> Lang.html shared ]

            Nothing ->
                Html.nothing
        , timer timeAnchor model
        , Html.div [ HtmlA.class "top-row" ] [ minorActions wrap shared auth game model.helpVisible ]
        ]
    , Html.div (HtmlA.class "round" :: roundAttrs) [ renderedCall, viewAction wrap shared action ]
    , content
    , Html.div [ HtmlA.class "scroll-top-spacer" ] []

    -- TODO: Hide this when at top. Waiting on native elm scroll events, as currently we'd have to ping constantly.
    , Html.div [ HtmlA.class "scroll-top" ]
        [ IconButton.view shared Strings.ScrollToTop (Icon.arrowUp |> Icon.present |> NeList.just) (ScrollToTop |> wrap |> Just) ]
    , renderDiscarded wrap shared config users model.discarded |> Maybe.withDefault Html.nothing
    ]


renderDiscarded : (Msg -> msg) -> Shared -> Config -> Dict User.Id User -> List ( User.Id, Card.Response ) -> Maybe (Html msg)
renderDiscarded wrap shared config users discarded =
    case discarded of
        ( player, card ) :: _ ->
            let
                name =
                    Dict.get player users
                        |> Maybe.map .name
                        |> Maybe.withDefault (Strings.UnknownUser |> Lang.string shared)
            in
            Html.div [ HtmlA.class "discarded", DismissDiscard |> wrap |> HtmlE.onClick ]
                [ Card.view [ NoOp |> wrap |> HtmlE.onClickNoPropagation ]
                    [ Html.span [ HtmlA.class "title" ]
                        [ Strings.Discarded { player = name } |> Lang.html shared
                        ]
                    , card |> Response.view shared config Card.Front []
                    , Button.view shared
                        Button.Standard
                        Strings.Accept
                        Strings.Accept
                        (Icon.check |> Icon.viewIcon)
                        [ DismissDiscard |> wrap |> HtmlE.onClick ]
                    ]
                ]
                |> Just

        [] ->
            Nothing


toggleHelp : (Msg -> msg) -> Shared -> Bool -> Html msg
toggleHelp wrap shared enabled =
    let
        extra =
            if enabled then
                [ Icon.slash |> Icon.present |> Icon.styled [ Icon.fw ] ]

            else
                []

        icon =
            Icon.question |> Icon.present |> Icon.styled [ Icon.fw ] |> NeList.just |> NeList.extend extra
    in
    IconButton.view shared Strings.ViewHelpAction icon (ToggleHelp |> wrap |> Just)


timer : Time.Anchor -> Model -> Html msg
timer timeAnchor model =
    let
        ( startedAt, limit, timedOut ) =
            roundTimeDetails model.game

        left =
            if timedOut then
                Just 0

            else
                Maybe.map2 (timeLeft timeAnchor startedAt) model.time limit
    in
    left |> Maybe.andThen timerInternal |> Maybe.withDefault (Html.div [ HtmlA.id "timer" ] [])


timerInternal : Int -> Maybe (Html msg)
timerInternal leftInt =
    let
        last =
            showProgressBarForLast |> toFloat

        left =
            leftInt |> toFloat
    in
    (1 - (last - left) / last) |> timerProgressBar


timerProgressBar : Float -> Maybe (Html msg)
timerProgressBar proportion =
    if proportion < 1 then
        let
            progress =
                proportion |> max 0 |> LinearProgress.Progress
        in
        LinearProgress.view progress [ HtmlA.id "timer" ] |> Just

    else
        Nothing


showProgressBarForLast : Int
showProgressBarForLast =
    15000


timeLeft : Time.Anchor -> Time -> Time -> Int -> Int
timeLeft anchor startedAt currentTime limit =
    let
        limitInMillis =
            limit * 1000

        timePassed =
            Time.millisecondsSince anchor startedAt currentTime
    in
    limitInMillis - timePassed


roundTimeDetails : Game -> ( Time, Maybe Int, Bool )
roundTimeDetails game =
    let
        stages =
            game.rules.stages
    in
    case game.round of
        Round.P playing ->
            ( playing.startedAt, stages.playing.duration, playing.timedOut )

        Round.R revealing ->
            ( revealing.startedAt, stages.revealing |> Maybe.andThen .duration, revealing.timedOut )

        Round.J judging ->
            ( judging.startedAt, stages.judging.duration, judging.timedOut )

        Round.C complete ->
            ( complete.startedAt, Nothing, False )


minorActions : (Msg -> msg) -> Shared -> Lobby.Auth -> Game -> Bool -> Html msg
minorActions wrap shared auth game helpEnabled =
    let
        localPlayer =
            game.players |> Dict.get auth.claims.uid

        ( _, _, timedOut ) =
            roundTimeDetails game

        enforceTimeLimit =
            if timedOut && game.rules.stages.mode == Rules.Soft then
                IconButton.view shared
                    Strings.EnforceTimeLimitAction
                    (Icon.forward |> Icon.present |> NeList.just)
                    (EnforceTimeLimit |> wrap |> Just)
                    |> Just

            else
                Nothing
    in
    Html.div [ HtmlA.id "minor-actions" ]
        (List.filterMap identity
            [ Just (historyButton wrap shared)
            , Just (toggleHelp wrap shared helpEnabled)
            , Maybe.map2 (\score -> \reboot -> rebootButton wrap shared score reboot)
                (localPlayer |> Maybe.map .score)
                game.rules.houseRules.reboot
            , game.rules.houseRules.neverHaveIEver |> Maybe.map (discardButton wrap shared game |> always)
            , enforceTimeLimit
            ]
        )


discardButton : (Msg -> msg) -> Shared -> Game -> Html msg
discardButton wrap shared game =
    let
        action =
            case game.round of
                Round.P p ->
                    Discard |> wrap |> Maybe.justIf (p.pick.cards |> Dict.size |> (==) 1)

                _ ->
                    Nothing
    in
    IconButton.view shared
        Strings.Discard
        (Icon.trash |> Icon.present |> NeList.just)
        action


historyButton : (Msg -> msg) -> Shared -> Html msg
historyButton wrap shared =
    IconButton.view shared
        Strings.ViewGameHistoryAction
        (Icon.history |> Icon.present |> NeList.just)
        (ToggleHistoryView |> wrap |> Just)


rebootButton : (Msg -> msg) -> Shared -> Int -> Rules.Reboot -> Html msg
rebootButton wrap shared score reboot =
    let
        action =
            if score < reboot.cost then
                Nothing

            else
                Redraw |> wrap |> Just
    in
    IconButton.view shared
        ({ cost = reboot.cost } |> Strings.HouseRuleRebootAction)
        (Icon.random |> Icon.present |> NeList.just)
        action


viewAction : (Msg -> msg) -> Shared -> Maybe Action -> Html msg
viewAction wrap shared visible =
    Html.div [] (Action.actions |> List.map (Action.view wrap shared visible))


gameOverlay : Shared -> MdString -> Maybe ( MdString, msg ) -> List (Html msg)
gameOverlay shared message action =
    [ Html.div [ HtmlA.id "game-overlay" ]
        [ Html.p [] [ message |> Lang.html shared ]
        , Html.p [] [ action |> Maybe.map (gameOverlayAction shared) |> Maybe.withDefault Html.nothing ]
        ]
    ]


gameOverlayAction : Shared -> ( MdString, msg ) -> Html msg
gameOverlayAction shared ( description, action ) =
    Components.linkButton [ action |> HtmlE.onClick ] [ description |> Lang.html shared ]


setPresence : User.Id -> Player.Presence -> User.Id -> Player -> Player
setPresence targetPlayer presence playerId player =
    if playerId == targetPlayer then
        { player | presence = presence }

    else
        player


speak : Shared -> Card.Call -> Maybe Parts.Fills -> Cmd msg
speak shared call play =
    Speech.speak shared.settings.settings.speech
        (Parts.viewFilledString
            (Strings.Blank |> Lang.string shared)
            (play |> Maybe.withDefault Dict.empty)
            call.body
        )


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


resolvePlayedBy : Dict Play.Id Play.Details -> Play.Known -> Maybe ( User.Id, Play.WithLikes )
resolvePlayedBy playedBy k =
    Dict.get k.id playedBy |> Maybe.map (\d -> ( d.playedBy, { play = k.responses, likes = d.likes } ))


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
