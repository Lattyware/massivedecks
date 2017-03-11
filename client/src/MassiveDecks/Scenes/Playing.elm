module MassiveDecks.Scenes.Playing exposing (update, view, init, subscriptions)

import Random
import String
import Html exposing (..)
import AnimationFrame
import MassiveDecks.API as API
import MassiveDecks.API.Request as Request
import MassiveDecks.Models exposing (Init)
import MassiveDecks.Components.Errors as Errors
import MassiveDecks.Components.TTS as TTS
import MassiveDecks.Models.Card as Card
import MassiveDecks.Models.Game.Round as Round exposing (Round)
import MassiveDecks.Scenes.Lobby.Models as Lobby
import MassiveDecks.Scenes.History as History
import MassiveDecks.Scenes.History.Messages as History
import MassiveDecks.Scenes.Playing.UI as UI
import MassiveDecks.Scenes.Playing.UI.Cards as CardsUI
import MassiveDecks.Scenes.Playing.Models exposing (Model, ShownPlayedCards, ShownCard)
import MassiveDecks.Scenes.Playing.Messages exposing (ConsumerMessage(..), Message(..))
import MassiveDecks.Scenes.Playing.HouseRule as HouseRule exposing (HouseRule)
import MassiveDecks.Scenes.Playing.HouseRule.Id as HouseRule
import MassiveDecks.Scenes.Playing.HouseRule.Reboot as Reboot
import MassiveDecks.Util as Util


{-| Create the initial model for the playing scene.
-}
init : Init -> Model
init init =
    { picked = []
    , considering = Nothing
    , finishedRound = Nothing
    , shownPlayed = { animated = [], toAnimate = [] }
    , seed = Random.initialSeed (hack init.seed)
    , history = Nothing
    }


houseRule : HouseRule.Id -> HouseRule
houseRule id =
    case id of
        HouseRule.Reboot ->
            Reboot.rule


{-| We shouldn't need to do this!
int flags blow up at the moment. For now, we pass a string, but we should take an int from JS in the future.
-}
hack : String -> Int
hack seed =
    String.toInt seed |> Result.withDefault 0


{-| Subscriptions for the playing scene.
-}
subscriptions : Model -> Sub ConsumerMessage
subscriptions model =
    if List.isEmpty model.shownPlayed.toAnimate then
        Sub.none
    else
        AnimationFrame.diffs (\_ -> LocalMessage AnimatePlayedCards)


{-| Render the playing scene.
-}
view : Lobby.Model -> Round -> ( List (Html ConsumerMessage), List (Html ConsumerMessage) )
view model round =
    let
        ( header, content ) =
            UI.view model round
    in
        ( header |> List.map (Html.map LocalMessage), content |> List.map (Html.map LocalMessage) )


{-| Handles messages and alters the model as appropriate.
-}
update : Message -> Lobby.Model -> Round -> ( Model, Cmd ConsumerMessage )
update message lobbyModel round =
    let
        model =
            lobbyModel.playing

        lobby =
            lobbyModel.lobby

        secret =
            lobbyModel.secret

        gameCode =
            lobby.gameCode
    in
        case message of
            Pick cardId ->
                let
                    slots =
                        Card.slots round.call

                    canPlay =
                        (List.length model.picked) < slots

                    playing =
                        case round.state of
                            Round.P _ ->
                                True

                            _ ->
                                False
                in
                    if playing && canPlay then
                        ( { model | picked = model.picked ++ [ cardId ] }, Cmd.none )
                    else
                        ( model, Cmd.none )

            Withdraw cardId ->
                ( { model | picked = List.filter ((/=) cardId) model.picked }, Cmd.none )

            Play ->
                ( { model | picked = [] }
                , Request.send (API.play gameCode secret model.picked) playErrorHandler ErrorMessage HandUpdate
                )

            Consider potentialWinnerIndex ->
                let
                    speech =
                        (case round.state of
                            Round.J judging ->
                                Util.get judging.responses potentialWinnerIndex |> Maybe.map (\fill -> ( round, fill ))

                            _ ->
                                Nothing
                        )
                            |> Maybe.map (\( round, callFill ) -> TTS.Say (CardsUI.callText round.call callFill) |> TTSMessage |> Util.cmd)
                            |> Maybe.withDefault Cmd.none
                in
                    ( { model | considering = Just potentialWinnerIndex }
                    , speech
                    )

            Choose winnerIndex ->
                ( { model | considering = Nothing }
                , Request.send (API.choose gameCode secret winnerIndex) chooseErrorHandler ErrorMessage ignore
                )

            NextRound ->
                ( { model
                    | considering = Nothing
                    , finishedRound = Nothing
                  }
                , Cmd.none
                )

            AnimatePlayedCards ->
                let
                    ( shownPlayed, seed ) =
                        updatePositioning model.shownPlayed model.seed
                in
                    ( { model
                        | seed = seed
                        , shownPlayed = shownPlayed
                      }
                    , Cmd.none
                    )

            Skip playerIds ->
                ( model, Request.send (API.skip gameCode secret playerIds) skipErrorHandler ErrorMessage ignore )

            Back ->
                ( model, Request.send_ (API.back gameCode secret) ErrorMessage ignore )

            LobbyAndHandUpdated ->
                lobbyAndHandUpdated lobbyModel round

            Redraw ->
                ( model, Request.send (API.redraw lobbyModel.lobby.gameCode lobbyModel.secret) redrawErrorHandler ErrorMessage HandUpdate )

            FinishRound finishedRound ->
                let
                    cards =
                        finishedRound.state.responses

                    winning =
                        Card.winningCards cards finishedRound.state.playedByAndWinner |> Maybe.withDefault []

                    speech =
                        Card.filled finishedRound.call winning
                in
                    ( { model | finishedRound = Just finishedRound }, TTS.Say speech |> TTSMessage |> Util.cmd )

            HistoryMessage historyMessage ->
                case model.history of
                    Just history ->
                        case historyMessage of
                            History.ErrorMessage errorMessage ->
                                ( model, ErrorMessage errorMessage |> Util.cmd )

                            History.Close ->
                                ( { model | history = Nothing }, Cmd.none )

                            History.LocalMessage localMessage ->
                                let
                                    ( newHistory, cmd ) =
                                        History.update localMessage history
                                in
                                    ( { model | history = Just newHistory }, Cmd.map (LocalMessage << HistoryMessage) cmd )

                    Nothing ->
                        ( model, Cmd.none )

            ViewHistory ->
                let
                    ( historyModel, command ) =
                        History.init lobbyModel.lobby.gameCode
                in
                    ( { model | history = Just historyModel }, Cmd.map (LocalMessage << HistoryMessage) command )

            NoOp ->
                ( model, Cmd.none )


ignore : () -> ConsumerMessage
ignore =
    (\_ -> LocalMessage NoOp)


lobbyAndHandUpdated : Lobby.Model -> Round -> ( Model, Cmd ConsumerMessage )
lobbyAndHandUpdated lobbyModel round =
    let
        lobby =
            lobbyModel.lobby

        model =
            lobbyModel.playing

        shownPlayed =
            model.shownPlayed

        playedCards =
            case round.state of
                Round.P playing ->
                    Just playing.numberPlayed

                _ ->
                    Nothing

        ( newShownPlayed, seed ) =
            case playedCards of
                Just amount ->
                    let
                        toShow =
                            amount * (Card.slots round.call)

                        existing =
                            (List.length shownPlayed.animated) + (List.length shownPlayed.toAnimate)

                        ( new, seed ) =
                            addShownPlayed (toShow - existing) model.seed
                    in
                        ( ShownPlayedCards shownPlayed.animated (shownPlayed.toAnimate ++ new), seed )

                Nothing ->
                    ( ShownPlayedCards [] [], model.seed )

        newModel =
            { model
                | shownPlayed = newShownPlayed
                , seed = seed
            }
    in
        ( newModel, Cmd.none )


redrawErrorHandler : API.RedrawError -> ConsumerMessage
redrawErrorHandler error =
    case error of
        API.NotEnoughPoints ->
            ErrorMessage <| Errors.New "You do not have enough points to redraw your hand." False


chooseErrorHandler : API.ChooseError -> ConsumerMessage
chooseErrorHandler error =
    case error of
        API.NotCzar ->
            ErrorMessage <| Errors.New "You can't pick a winner as you are not the card czar this round." False


playErrorHandler : API.PlayError -> ConsumerMessage
playErrorHandler error =
    case error of
        API.NotInRound ->
            ErrorMessage <| Errors.New "You can't play as you are not in this round." False

        API.AlreadyPlayed ->
            ErrorMessage <| Errors.New "You can't play as you have already played in this round." False

        API.AlreadyJudging ->
            ErrorMessage <| Errors.New "You can't play as the round is already in it's judging phase." False

        API.WrongNumberOfCards got expected ->
            ErrorMessage <| Errors.New ("You played the wrong number of cards - you played " ++ (toString got) ++ " cards, but the call needs " ++ (toString expected) ++ "cards.") False


skipErrorHandler : API.SkipError -> ConsumerMessage
skipErrorHandler error =
    case error of
        API.NotEnoughPlayersToSkip required ->
            ErrorMessage <| Errors.New ("There are not enough players in the game to skip (must have at least " ++ (toString required) ++ ").") False

        API.PlayersNotSkippable ->
            ErrorMessage <| Errors.New "The players can't be skipped as they are not inactive." False


addShownPlayed : Int -> Random.Seed -> ( List ShownCard, Random.Seed )
addShownPlayed new seed =
    Random.step (Random.list new initialRandomPositioning) seed


updatePositioning : ShownPlayedCards -> Random.Seed -> ( ShownPlayedCards, Random.Seed )
updatePositioning shownPlayed seed =
    let
        ( newAnimated, newSeed ) =
            Random.step (Random.list (List.length shownPlayed.toAnimate) randomPositioning) seed
    in
        ( ShownPlayedCards (shownPlayed.animated ++ newAnimated) [], newSeed )


initialRandomPositioning : Random.Generator ShownCard
initialRandomPositioning =
    Random.map3 (\r h l -> ShownCard r h l -100)
        (Random.int -75 75)
        (Random.int 0 50)
        Random.bool


randomPositioning : Random.Generator ShownCard
randomPositioning =
    Random.map4 ShownCard
        (Random.int -90 90)
        (Random.int 25 50)
        Random.bool
        (Random.int -5 1)
