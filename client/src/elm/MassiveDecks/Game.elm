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
import Dict exposing (Dict)
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html)
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import MassiveDecks.Card as Card
import MassiveDecks.Card.Call as Call
import MassiveDecks.Card.Model as Card exposing (Call)
import MassiveDecks.Card.Parts as Parts
import MassiveDecks.Card.Play as Play exposing (Play)
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
import MassiveDecks.Pages.Lobby.Model as Lobby exposing (Lobby)
import MassiveDecks.Speech as Speech
import MassiveDecks.Strings as Strings exposing (MdString)
import MassiveDecks.Strings.Languages as Lang
import MassiveDecks.User as User exposing (User)
import MassiveDecks.Util.Html as Html
import MassiveDecks.Util.Maybe as Maybe
import Set exposing (Set)
import Task
import Weightless as Wl
import Weightless.Attributes as WlA
import Weightless.ProgressBar as ProgressBar


init : (Msg -> msg) -> Game -> List Card.PotentiallyBlankResponse -> Round.Pick -> ( Model, Cmd msg )
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
        Pick played ->
            case game.round of
                Round.P playingRound ->
                    let
                        picks =
                            playingRound.pick

                        picked =
                            if picks.cards |> List.map .id |> List.member played.id then
                                List.filter (\p -> p.id /= played.id) picks.cards

                            else
                                picks.cards ++ [ played ]

                        extra =
                            max 0 (List.length picked - (playingRound.call |> Call.slotCount))

                        newRound =
                            Round.P { playingRound | pick = { picks | cards = picked |> List.drop extra } }
                    in
                    ( { model | game = { game | round = newRound } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        EditBlank id text ->
            case game.round of
                Round.P playingRound ->
                    if playingRound.pick.cards |> List.all (\p -> p.id /= id) then
                        ( { model | filledCards = model.filledCards |> Dict.insert id text }, Cmd.none )

                    else
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PickPlay id ->
            let
                newRound =
                    case game.round of
                        Round.J judging ->
                            let
                                pick =
                                    if judging.pick == Just id then
                                        Nothing

                                    else
                                        Just id
                            in
                            { judging | pick = pick } |> Round.J

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
                    case game.round of
                        Round.J judging ->
                            ( { judging
                                | liked =
                                    judging.pick
                                        |> Maybe.map (\p -> Set.insert p judging.liked)
                                        |> Maybe.withDefault judging.liked
                              }
                                |> Round.J
                            , judging.pick |> Maybe.map Actions.like |> Maybe.withDefault Cmd.none
                            )

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

        NoOp ->
            ( model, Cmd.none )


subscriptions : (Msg -> msg) -> Time.Anchor -> Model -> Sub msg
subscriptions wrap anchor model =
    let
        ( startedAt, maybeLimitSeconds, timedOut ) =
            roundTimeDetails model.game
    in
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


view : (Msg -> msg) -> Shared -> Lobby.Auth -> Time.Anchor -> String -> Config -> Dict User.Id User -> Model -> Html msg
view wrap shared auth timeAnchor name config users model =
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
                        viewWinner shared users winners

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

                players =
                    game.players |> Dict.map updatePlayer
            in
            ( { model | game = { game | players = players }, hand = newHand }, Cmd.none )

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
                                        time
                                        False
                                        |> Round.R

                                picked =
                                    r.pick.cards |> List.map .id |> Set.fromList

                                newHand =
                                    model.hand
                                        |> List.filter (\c -> not (Set.member (Card.details c).id picked))
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

                        { newRound, history, speech, newPlayers } =
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

                                        tts =
                                            Dict.get winner playsDict
                                                |> Maybe.map (\p -> speak shared r.call (Just p.play))
                                                |> Maybe.withDefault Cmd.none

                                        ps =
                                            playersWithWinner |> Dict.map (updateLikes playsDict)
                                    in
                                    { newRound = complete |> Round.C
                                    , history = complete :: game.history
                                    , speech = tts
                                    , newPlayers = ps
                                    }

                                _ ->
                                    -- TODO: Error
                                    { newRound = game.round
                                    , history = game.history
                                    , speech = Cmd.none
                                    , newPlayers = playersWithWinner
                                    }
                    in
                    ( { model
                        | game =
                            { game
                                | round = newRound
                                , players = newPlayers
                                , history = history
                            }
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

                                        known =
                                            plays |> List.filterMap Play.asKnown

                                        round =
                                            if List.length known == List.length plays then
                                                Round.judging r.id r.czar r.players r.call known time False |> Round.J

                                            else
                                                { r | plays = plays, lastRevealed = Just id } |> Round.R

                                        tts =
                                            speak shared r.call (Just play)
                                    in
                                    ( round, tts )

                                _ ->
                                    -- TODO: Error
                                    ( model.game.round, Cmd.none )
                    in
                    ( { model | game = { game | round = newRound } }, speech )

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
            ( { model | game = { game | winner = Just winner } }, Cmd.none )


applyGameStarted : (Msg -> msg) -> Lobby -> Round.Playing -> List Card.PotentiallyBlankResponse -> ( Model, Cmd msg )
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


hotJoinPlayer : User.Id -> Model -> Model
hotJoinPlayer player model =
    let
        oldGame =
            model.game

        game =
            { oldGame
                | players = oldGame.players |> Dict.insert player Player.default
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


viewWinner : Shared -> Dict User.Id User -> Set User.Id -> List (Html msg)
viewWinner shared users winners =
    [ Wl.card [ HtmlA.id "game-winner" ]
        [ Html.span [] [ Icon.trophy |> Icon.viewIcon ]
        , Html.ul [] (winners |> Set.toList |> List.map (viewWinnerListItem shared users))
        ]
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
        ( call, { instruction, action, content, fillCallWith } ) =
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

        parts =
            fillCallWith |> List.map .body

        renderedCall =
            call |> Call.viewFilled shared config Card.Front [] parts

        { bar, countdown } =
            timer timeAnchor model
    in
    [ Html.div [ HtmlA.id "top-content" ]
        [ bar |> Maybe.withDefault Html.nothing
        , Html.div [ HtmlA.class "top-row" ]
            [ minorActions wrap shared auth game instruction
            , countdown |> Maybe.withDefault Html.nothing
            ]
        ]
    , Html.div [ HtmlA.class "round" ] [ renderedCall, viewAction wrap shared action ]
    , content
    , Html.div [ HtmlA.class "scroll-top-spacer" ] []

    -- TODO: Hide this when at top. Waiting on native elm scroll events, as currently we'd have to ping constantly.
    , Html.div [ HtmlA.class "scroll-top" ]
        [ Wl.button
            [ WlA.flat
            , WlA.fab
            , WlA.inverted
            , ScrollToTop |> wrap |> HtmlE.onClick
            ]
            [ Icon.viewIcon Icon.arrowUp ]
        ]
    ]


help : Shared -> MdString -> Html msg
help shared instruction =
    let
        id =
            "context-help-button"

        helpContent =
            [ Components.iconButton
                [ HtmlA.id id, Strings.ViewHelpAction |> Lang.title shared ]
                Icon.question
            , Wl.popover
                (List.concat
                    [ WlA.anchorOrigin WlA.XCenter WlA.YBottom
                    , WlA.transformOrigin WlA.XLeft WlA.YTop
                    , [ WlA.anchor id, WlA.fixed, WlA.anchorOpenEvents [ "click" ] ]
                    ]
                )
                [ Wl.popoverCard [] [ instruction |> Lang.html shared ] ]
            ]
    in
    Html.div [ HtmlA.id "context-help" ] helpContent


timer : Time.Anchor -> Model -> { bar : Maybe (Html msg), countdown : Maybe (Html msg) }
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
    left |> Maybe.map timerInternal |> Maybe.withDefault { bar = Nothing, countdown = Nothing }


timerInternal : Int -> { bar : Maybe (Html msg), countdown : Maybe (Html msg) }
timerInternal leftInt =
    let
        last =
            showProgressBarForLast |> toFloat

        left =
            leftInt |> toFloat

        progressBar =
            (1 - (last - left) / last)
                |> timerProgressBar
    in
    { bar = progressBar
    , countdown = Just (Html.div [ HtmlA.id "time-left" ] [ max 0 left / 1000 |> ceiling |> String.fromInt |> Html.text ])
    }


timerProgressBar : Float -> Maybe (Html msg)
timerProgressBar proportion =
    if proportion < 1 then
        ProgressBar.determinate (min 1 (max 0 proportion)) [ HtmlA.id "timer" ] |> Just

    else
        Nothing


showProgressBarForLast : Int
showProgressBarForLast =
    20000


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
        timeLimits =
            game.rules.timeLimits
    in
    case game.round of
        Round.P playing ->
            ( playing.startedAt, timeLimits.playing, playing.timedOut )

        Round.R revealing ->
            ( revealing.startedAt, timeLimits.revealing, revealing.timedOut )

        Round.J judging ->
            ( judging.startedAt, timeLimits.judging, judging.timedOut )

        Round.C complete ->
            ( complete.startedAt, Nothing, False )


minorActions : (Msg -> msg) -> Shared -> Lobby.Auth -> Game -> Maybe MdString -> Html msg
minorActions wrap shared auth game instruction =
    let
        localPlayer =
            game.players |> Dict.get auth.claims.uid

        ( _, _, timedOut ) =
            roundTimeDetails game

        enforceTimeLimit =
            if timedOut && game.rules.timeLimits.mode == Rules.Soft then
                Components.iconButton
                    [ Strings.EnforceTimeLimitAction |> Lang.title shared
                    , EnforceTimeLimit |> wrap |> HtmlE.onClick
                    ]
                    Icon.forward
                    |> Just

            else
                Nothing
    in
    Html.div [ HtmlA.id "minor-actions" ]
        (List.filterMap identity
            [ Just (historyButton wrap shared)
            , instruction |> Maybe.map (help shared)
            , Maybe.map2 (\score -> \reboot -> rebootButton wrap shared score reboot)
                (localPlayer |> Maybe.map .score)
                game.rules.houseRules.reboot
            , enforceTimeLimit
            ]
        )


historyButton : (Msg -> msg) -> Shared -> Html msg
historyButton wrap shared =
    Components.iconButton
        [ HtmlA.id "history-button"
        , Strings.ViewGameHistoryAction |> Lang.title shared
        , ToggleHistoryView |> wrap |> HtmlE.onClick
        ]
        Icon.history


rebootButton : (Msg -> msg) -> Shared -> Int -> Rules.Reboot -> Html msg
rebootButton wrap shared score reboot =
    Components.iconButton
        [ HtmlA.id "redraw"
        , { cost = reboot.cost } |> Strings.HouseRuleRebootAction |> Lang.title shared
        , WlA.disabled
            |> Maybe.justIf (score < reboot.cost)
            |> Maybe.withDefault (Redraw |> wrap |> HtmlE.onClick)
        ]
        Icon.random


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


speak : Shared -> Card.Call -> Maybe (List Card.Response) -> Cmd msg
speak shared call play =
    Speech.speak shared.settings.settings.speech
        (Parts.viewFilledString
            (Strings.Blank |> Lang.string shared)
            (play |> Maybe.map (List.map .body) |> Maybe.withDefault [])
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
