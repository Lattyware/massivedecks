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

        round =
            model.game.round

        ( newRound, roundCmd ) =
            case round.stage of
                Round.P stage ->
                    let
                        ( playing, cmd ) =
                            Playing.init wrap (Round.withStage stage round) pick
                    in
                    ( playing, cmd )

                _ ->
                    ( round, Cmd.none )

        timeCmd =
            Time.now (UpdateTimer >> wrap)
    in
    ( { model | hand = hand, game = { game | round = newRound } }, Cmd.batch [ roundCmd, timeCmd ] )


update : (Msg -> msg) -> Shared -> Msg -> Model -> ( Model, Cmd msg )
update wrap shared msg model =
    let
        game =
            model.game

        round =
            game.round
    in
    case msg of
        Pick maybeFor played ->
            case round.stage of
                Round.P stage ->
                    let
                        picks =
                            stage.pick

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
                                                Parts.missingSlotIndices picks.cards round.call.body |> Set.toList
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

                        newStage =
                            Round.P { stage | pick = { picks | cards = picked } }

                        focus =
                            Dom.focus played
                                |> Task.onError (\_ -> Task.succeed ())
                                |> Task.perform (\_ -> wrap NoOp)
                    in
                    ( { model | game = { game | round = { round | stage = newStage } } }, focus )

                _ ->
                    ( model, Cmd.none )

        Unpick slotId ->
            case round.stage of
                Round.P stage ->
                    let
                        picks =
                            stage.pick

                        picked =
                            picks.cards |> Dict.remove slotId

                        newStage =
                            Round.P { stage | pick = { picks | cards = picked } }
                    in
                    ( { model | game = { game | round = { round | stage = newStage } } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Drag dragDropMsg ->
            let
                ( dragDrop, result ) =
                    DragDrop.update dragDropMsg model.dragDrop

                newStage =
                    case round.stage of
                        Round.P stage ->
                            let
                                picks =
                                    stage.pick

                                picked =
                                    case result of
                                        Just ( card, slotIndex, _ ) ->
                                            picks.cards
                                                |> Dict.filter (\_ p -> p /= card)
                                                |> Dict.insert slotIndex card

                                        Nothing ->
                                            picks.cards
                            in
                            Round.P { stage | pick = { picks | cards = picked } }

                        stage ->
                            stage
            in
            ( { model | game = { game | round = { round | stage = newStage } }, dragDrop = dragDrop }, Cmd.none )

        EditBlank id text ->
            case round.stage of
                Round.P stage ->
                    if stage.pick.state /= Round.Submitted then
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
                makePick stage wrapRound =
                    let
                        pick =
                            if stage.pick == Just id then
                                Nothing

                            else
                                Just id
                    in
                    { stage | pick = pick } |> wrapRound

                newStage =
                    case round.stage of
                        Round.J stage ->
                            makePick stage Round.J

                        Round.R stage ->
                            makePick stage Round.R

                        Round.C stage ->
                            makePick stage Round.C

                        stage ->
                            stage
            in
            ( { model | game = { game | round = { round | stage = newStage } } }, Cmd.none )

        Submit ->
            case round.stage of
                Round.P stage ->
                    let
                        picks =
                            stage.pick

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

                        newStage =
                            Round.P { stage | pick = { picks | state = Round.Submitted } }
                    in
                    ( { model | game = { game | round = { round | stage = newStage } } }
                    , Cmd.batch (fills ++ [ picks.cards |> Dict.values |> Actions.submit ])
                    )

                _ ->
                    ( model, Cmd.none )

        TakeBack ->
            case round.stage of
                Round.P stage ->
                    let
                        picks =
                            stage.pick

                        newStage =
                            Round.P { stage | pick = { picks | state = Round.Selected } }
                    in
                    ( { model | game = { game | round = { round | stage = newStage } } }, Actions.takeBack )

                _ ->
                    ( model, Cmd.none )

        ScrollToTop ->
            ( model, Dom.setViewportOf "scroll-frame" 0 0 |> Task.attempt (NoOp |> wrap |> always) )

        Reveal play ->
            ( model, Actions.reveal play )

        Judge ->
            let
                ( newStage, cmd ) =
                    case round.stage of
                        Round.J stage ->
                            ( Round.J { stage | pick = Nothing }
                            , stage.pick |> Maybe.map Actions.judge |> Maybe.withDefault Cmd.none
                            )

                        stage ->
                            ( stage, Cmd.none )
            in
            ( { model | game = { game | round = { round | stage = newStage } } }, cmd )

        Like ->
            let
                ( newStage, action ) =
                    let
                        like stage roundWrap =
                            let
                                likeDetail =
                                    stage.likeDetail

                                insert =
                                    stage.pick
                                        |> Maybe.map Set.insert
                                        |> Maybe.withDefault identity

                                newLikeDetail =
                                    { likeDetail | liked = insert likeDetail.liked }
                            in
                            ( { stage | pick = Nothing, likeDetail = newLikeDetail } |> roundWrap
                            , stage.pick |> Maybe.map Actions.like |> Maybe.withDefault Cmd.none
                            )
                    in
                    case round.stage of
                        Round.J stage ->
                            like stage Round.J

                        Round.R stage ->
                            like stage Round.R

                        Round.C stage ->
                            like stage Round.C

                        stage ->
                            ( stage, Cmd.none )
            in
            ( { model | game = { game | round = { round | stage = newStage } } }, action )

        SetPlayStyles playStyles ->
            ( { model | playStyles = playStyles }, Cmd.none )

        AdvanceRound ->
            case model.completeRound of
                Just _ ->
                    let
                        tts =
                            speak shared round.call Nothing
                    in
                    ( { model | completeRound = Nothing }
                    , tts
                    )

                Nothing ->
                    ( model, Cmd.none )

        Redraw ->
            ( model, Actions.redraw )

        Discard ->
            case round.stage of
                Round.P stage ->
                    let
                        action =
                            stage.pick.cards |> Dict.values |> List.head |> Maybe.map Actions.discard
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
            ( model, Actions.enforceTimeLimit round.id (round.stage |> Round.stage) )

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
    let
        game =
            model.game

        round =
            game.round
    in
    case gameEvent of
        Events.HandRedrawn { player, hand } ->
            let
                -- TODO: Error, if the rule isn't enabled, we are out of sync.
                cost =
                    game.rules.houseRules.reboot |> Maybe.map .cost |> Maybe.withDefault 0

                updatePlayer =
                    \id -> \p -> { p | score = p.score - cost } |> Maybe.justIf (player == id) |> Maybe.withDefault p

                -- TODO: Error, if we get a hand but the event claims another player, we are out of sync.
                newHand =
                    hand |> Maybe.andThen (Maybe.justIf (player == auth.claims.uid)) |> Maybe.withDefault model.hand

                newStage =
                    if player == auth.claims.uid then
                        case round.stage of
                            Round.P playing ->
                                let
                                    pick =
                                        playing.pick
                                in
                                Round.P { playing | pick = { pick | cards = Dict.empty } }

                            stage ->
                                stage

                    else
                        round.stage

                players =
                    game.players |> Dict.map updatePlayer
            in
            ( { model | game = { game | players = players, round = { round | stage = newStage } }, hand = newHand }, Cmd.none )

        Events.PlaySubmitted { by } ->
            case round.stage of
                Round.P stage ->
                    let
                        newStage =
                            Round.P { stage | played = Set.insert by stage.played }
                    in
                    ( { model | game = { game | round = { round | stage = newStage } } }
                    , Cmd.none
                    )

                _ ->
                    -- TODO: Error
                    ( model, Cmd.none )

        Events.PlayTakenBack { by } ->
            case round.stage of
                Round.P stage ->
                    let
                        newStage =
                            Round.P { stage | played = Set.remove by stage.played }
                    in
                    ( { model | game = { game | round = { round | stage = newStage } } }
                    , Cmd.none
                    )

                _ ->
                    -- TODO: Error
                    ( model, Cmd.none )

        Events.PlayLiked { play } ->
            case round.stage of
                Round.C stage ->
                    let
                        increment withLikes =
                            { withLikes | likes = withLikes.likes |> Maybe.withDefault 0 |> (+) 1 |> Just }

                        playedBy =
                            stage.plays |> Dict.get play |> Maybe.map .playedBy

                        incrementPlayer player =
                            { player | likes = player.likes + 1 }

                        updatePlayer player =
                            game.players |> Dict.update player (Maybe.map incrementPlayer)

                        players =
                            playedBy |> Maybe.map updatePlayer |> Maybe.withDefault game.players

                        newStage =
                            { stage | plays = Dict.update play (Maybe.map increment) stage.plays }
                    in
                    ( { model | game = { game | players = players, round = { round | stage = Round.C newStage } } }
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
                    case round.stage of
                        Round.P r ->
                            let
                                { played, drawn } =
                                    afterPlaying

                                oldGame =
                                    model.game

                                newStage =
                                    Round.Revealing
                                        { played = played, liked = Set.empty }
                                        Nothing
                                        Nothing
                                        (plays |> List.map (\id -> Play id Nothing))
                                        False
                                        |> Round.R

                                picked =
                                    r.pick.cards |> Dict.values |> Set.fromList

                                newHand =
                                    model.hand
                                        |> List.filter (\c -> not (Set.member c.details.id picked))
                                        |> (\h -> h ++ (drawn |> Maybe.withDefault []))

                                role =
                                    Player.role round auth.claims.uid

                                notification =
                                    if role == Player.RCzar then
                                        Notifications.notify shared
                                            { title = Strings.JudgingStarted
                                            , body = Strings.RevealPlaysInstruction
                                            }

                                    else
                                        Cmd.none
                            in
                            ( { model | game = { oldGame | round = Round.withStage newStage round }, hand = newHand }
                            , notification
                            )

                        _ ->
                            -- TODO: Error
                            ( model, Cmd.none )

                Events.RoundFinished { winner, playedBy } ->
                    let
                        playersWithWinner =
                            game.players |> Dict.update winner (Maybe.map (\p -> { p | score = p.score + 1 }))

                        { newRound, history, speech, newPlayers, filledCards } =
                            case round.stage of
                                Round.J r ->
                                    let
                                        ( plays, playOrder ) =
                                            resolvePlayedBy r.plays playedBy

                                        complete =
                                            Round.Complete
                                                r.likeDetail
                                                r.pick
                                                plays
                                                playOrder
                                                winner

                                        handIds =
                                            model.hand |> List.map (.details >> .id) |> Set.fromList

                                        isStillInHand id _ =
                                            Set.member id handIds

                                        tts =
                                            Dict.get winner plays
                                                |> Maybe.map (\p -> speak shared round.call (p.play |> Parts.fillsFromPlay |> Just))
                                                |> Maybe.withDefault Cmd.none

                                        ps =
                                            playersWithWinner |> updateLikes plays
                                    in
                                    { newRound = Round.withStage (Round.C complete) round
                                    , history = Round.withStage complete round :: game.history
                                    , speech = tts
                                    , newPlayers = ps
                                    , filledCards = model.filledCards |> Dict.filter isStillInHand
                                    }

                                _ ->
                                    -- TODO: Error
                                    { newRound = round
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
                        drawnAsList =
                            drawn |> Maybe.withDefault []

                        ( newRound, cmd ) =
                            let
                                r =
                                    { id = id
                                    , czar = czar
                                    , players = players
                                    , call = call
                                    , startedAt = time
                                    , stage = Round.Playing Round.noPick Set.empty False
                                    }
                            in
                            Playing.init wrap r Round.noPick

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
                                case round.stage of
                                    Round.C stage ->
                                        round |> Round.withStage stage |> Just

                                    _ ->
                                        Nothing
                    in
                    ( { model
                        | game = { game | round = newRound }
                        , completeRound = completeRound
                        , hand = model.hand ++ drawnAsList
                      }
                    , Cmd.batch [ cmd, notification ]
                    )

                Events.PlayRevealed { id, play } ->
                    let
                        ( newRound, speech ) =
                            case round.stage of
                                Round.R stage ->
                                    let
                                        plays =
                                            stage.plays |> List.map (reveal id play)

                                        newStage =
                                            { stage | plays = plays, lastRevealed = Just id } |> Round.R

                                        tts =
                                            speak shared round.call (play |> Parts.fillsFromPlay |> Just)
                                    in
                                    ( { round | stage = newStage }, tts )

                                _ ->
                                    -- TODO: Error
                                    ( round, Cmd.none )
                    in
                    ( { model | game = { game | round = newRound } }, speech )

                Events.StartJudging { plays, afterPlaying } ->
                    let
                        { played, drawn } =
                            afterPlaying

                        makeNewRound stage pick ld known =
                            case known of
                                Just k ->
                                    Round.Judging
                                        ld
                                        pick
                                        k
                                        False
                                        |> Round.J

                                Nothing ->
                                    -- TODO: Error.
                                    stage

                        ( newStage, newHand ) =
                            case round.stage of
                                Round.P stage ->
                                    let
                                        picked =
                                            stage.pick.cards |> Dict.values |> Set.fromList

                                        nH =
                                            model.hand
                                                |> List.filter (\c -> not (Set.member c.details.id picked))
                                                |> (\h -> h ++ (drawn |> Maybe.withDefault []))
                                    in
                                    ( makeNewRound round.stage Nothing { played = played, liked = Set.empty } plays
                                    , nH
                                    )

                                Round.R stage ->
                                    let
                                        p =
                                            plays
                                                |> Maybe.withDefault (stage.plays |> List.filterMap Play.asKnown)
                                                |> Just
                                    in
                                    ( makeNewRound round.stage stage.pick stage.likeDetail p, model.hand )

                                stage ->
                                    -- TODO: Error.
                                    ( stage, model.hand )
                    in
                    ( { model | game = { game | round = { round | stage = newStage } }, hand = newHand }, Cmd.none )

        Events.PlayerAway { player } ->
            let
                players =
                    game.players |> Dict.map (setPresence player Player.Away)
            in
            ( { model | game = { game | players = players } }, Cmd.none )

        Events.PlayerBack { player } ->
            let
                players =
                    game.players |> Dict.map (setPresence player Player.Active)
            in
            ( { model | game = { game | players = players } }, Cmd.none )

        Events.Paused ->
            ( { model | game = { game | paused = True } }, Cmd.none )

        Events.Continued ->
            ( { model | game = { game | paused = False } }, Cmd.none )

        Events.StageTimerDone details ->
            let
                oldRound =
                    round
            in
            if oldRound.id == details.round && Round.stage oldRound.stage == details.stage then
                let
                    newStage =
                        case oldRound.stage of
                            Round.P playing ->
                                Round.P { playing | timedOut = True }

                            Round.R revealing ->
                                Round.R { revealing | timedOut = True }

                            Round.J judging ->
                                Round.J { judging | timedOut = True }

                            Round.C complete ->
                                Round.C complete
                in
                ( { model | game = { game | round = { oldRound | stage = newStage } } }, Cmd.none )

            else
                ( model, Cmd.none )

        Events.GameEnded { winner } ->
            ( { model | game = { game | winner = Just winner }, confetti = False }, Cmd.none )

        Events.CardDiscarded { player, card, replacement } ->
            let
                ( hand, stage, discarded ) =
                    case replacement of
                        Just replacementCard ->
                            let
                                replace c =
                                    if c.details.id == card.details.id then
                                        replacementCard

                                    else
                                        c

                                newStage =
                                    case round.stage of
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
                            ( model.hand |> List.map replace, newStage, model.discarded )

                        Nothing ->
                            ( model.hand, round.stage, model.discarded ++ [ ( player, card ) ] )
            in
            ( { model | hand = hand, discarded = discarded, game = { game | round = { round | stage = stage } } }
            , Cmd.none
            )


applyGameStarted : (Msg -> msg) -> Lobby -> Round -> List Card.Response -> ( Model, Cmd msg )
applyGameStarted wrap lobby round hand =
    let
        users =
            lobby.users |> Dict.toList |> List.map (\( id, _ ) -> id)

        game =
            { round = round
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


resolvePlayedBy :
    List Play.Known
    -> Dict Play.Id Play.Details
    -> ( Dict Play.Id Play.WithDetails, List Play.Id )
resolvePlayedBy knownPlays details =
    let
        step known ( plays, playOrder ) =
            let
                newPs =
                    case details |> Dict.get known.id of
                        Just { playedBy, likes } ->
                            plays |> Dict.insert known.id (Play.WithDetails known.responses playedBy likes)

                        Nothing ->
                            plays
            in
            ( newPs, known.id :: playOrder )
    in
    knownPlays |> List.foldr step ( Dict.empty, [] )


updateLikes : Dict Play.Id Play.WithDetails -> Dict User.Id Player -> Dict User.Id Player
updateLikes plays initialPlayers =
    let
        incrementBy likes player =
            { player | likes = player.likes + likes }

        step _ play players =
            case play.likes of
                Just likes ->
                    players |> Dict.update play.playedBy (Maybe.map (incrementBy likes))

                Nothing ->
                    players
    in
    plays |> Dict.foldl step initialPlayers


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
        round =
            model.game.round

        ( call, { instruction, action, content, slotAttrs, fillCallWith, roundAttrs } ) =
            case model.completeRound of
                Just completeRound ->
                    ( completeRound.call, Complete.view wrap shared True config users completeRound )

                Nothing ->
                    case round.stage of
                        Round.P stage ->
                            ( round.call, Playing.view wrap auth shared config users model (Round.withStage stage round) )

                        Round.R stage ->
                            ( round.call, Revealing.view wrap auth shared users config (Round.withStage stage round) )

                        Round.J stage ->
                            ( round.call, Judging.view wrap auth shared users config (Round.withStage stage round) )

                        Round.C stage ->
                            ( round.call, Complete.view wrap shared False config users (Round.withStage stage round) )

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
    , Html.div (HtmlA.class "round" :: roundAttrs) [ renderedCall, Action.view wrap shared action ]
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

        round =
            game.round
    in
    case round.stage of
        Round.P playing ->
            ( round.startedAt, stages.playing.duration, playing.timedOut )

        Round.R revealing ->
            ( round.startedAt, stages.revealing |> Maybe.andThen .duration, revealing.timedOut )

        Round.J judging ->
            ( round.startedAt, stages.judging.duration, judging.timedOut )

        Round.C _ ->
            ( round.startedAt, Nothing, False )


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
            case game.round.stage of
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
