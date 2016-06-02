module MassiveDecks.Scenes.Lobby.Event exposing (Event(..), events)

import MassiveDecks.Models.Game as Game
import MassiveDecks.Models.Player as Player exposing (Player)
import MassiveDecks.Models.Card as Card
import MassiveDecks.Util as Util


{-| Events represent high-level changes in the game. When the game state is updated, it is checked to determine if the
game has changed and events should be fired. This means that these checks only need to be done in one place.
The use case for events is where something ephemeral needs to happen as a result of a change in the game state
(e.g: an animation or notification).
-}
type Event
  = PlayerJoin Player.Id
  | PlayerStatus Player.Id Player.Status
  | PlayerLeft Player.Id
  | PlayerDisconnect Player.Id
  | PlayerReconnect Player.Id
  | PlayerScore Player.Id Int
  | RoundStart Card.Call Player.Id
  | RoundPlayed Int
  | RoundJudging (List Card.PlayedCards)
  | RoundEnd Card.Call Player.Id (List Card.PlayedCards) Player.PlayedByAndWinner


{-| Generate events from a given change in lobby.
Essentially, this does a diff between the two lobbies, and then generates events based on the differences. If there is
an extra player in the new lobby, a `PlayerJoin` event will be produced.
-}
events : Game.Lobby -> Game.Lobby -> List Event
events oldLobby newLobby = List.concat
  [ diffPlayers oldLobby.players newLobby.players
  , diffRound oldLobby.round newLobby.round
  ]


{- Private -}


diffPlayers : List Player -> List Player -> List Event
diffPlayers oldPlayers newPlayers =
  List.concatMap (diffPlayer oldPlayers) newPlayers

diffPlayer : List Player -> Player -> List Event
diffPlayer oldPlayers newPlayer =
  let
    id = newPlayer.id
    oldPlayer = List.filter (\player -> player.id == id) oldPlayers |> List.head
  in
    case oldPlayer of
      Just oldPlayer ->
        List.concat
          [ if oldPlayer.status /= newPlayer.status then  [ playerStatus newPlayer ] else []
          , if oldPlayer.score /= newPlayer.score then [ playerScore newPlayer ] else []
          , if (not oldPlayer.left) && newPlayer.left then [ playerLeft newPlayer ] else []
          , if (not oldPlayer.disconnected) && newPlayer.disconnected then [ playerDisconnect newPlayer ] else []
          , if oldPlayer.disconnected && (not newPlayer.disconnected) then [ playerReconnect newPlayer ] else []
          ]

      Nothing ->
        Util.apply [ playerJoin, playerStatus, playerScore ] newPlayer


diffRound : Maybe Game.Round -> Maybe Game.Round -> List Event
diffRound oldRound newRound =
  let
    differentRounds = (Maybe.map .call oldRound) /= (Maybe.map .call newRound)

    start = case newRound of
      Just round -> if differentRounds then [ roundStart round ] else []
      Nothing ->
        []

    played = if differentRounds then [] else case newRound of
      Just round ->
        let
          oldCount = playedInRound oldRound |> Maybe.withDefault 0
          newCount = playedInRound newRound |> Maybe.withDefault 0
        in
          if oldCount < newCount then [ RoundPlayed (newCount - oldCount) ] else []
      Nothing ->
        []

    judging = case newRound of
      Just round ->
        case round.responses of
          Card.Hidden _ ->
            []
          Card.Revealed responses ->
            let
              oldJudging = Maybe.map (\or -> case or.responses of
                Card.Hidden _ -> False
                Card.Revealed oldResponses -> Util.isNothing oldResponses.playedByAndWinner) oldRound |> Maybe.withDefault False
              newJudging = Util.isNothing responses.playedByAndWinner
            in
              if newJudging && ((not oldJudging) || (oldJudging && differentRounds)) then
                [ RoundJudging responses.cards ]
              else
                []
      Nothing ->
        []

    ended = case newRound of
      Just round ->
        case round.responses of
          Card.Hidden _ ->
            []
          Card.Revealed responses ->
            case responses.playedByAndWinner of
              Nothing ->
                []
              Just playedByAndWinner ->
                let
                  oldEnded = Maybe.map (\or -> case or.responses of
                    Card.Hidden _ -> False
                    Card.Revealed oldResponses -> not (Util.isNothing oldResponses.playedByAndWinner)) oldRound |> Maybe.withDefault False
                in
                  if (not oldEnded) || (oldEnded && differentRounds) then
                    [ RoundEnd round.call round.czar responses.cards playedByAndWinner ]
                  else
                    []
      Nothing ->
        []
  in
    List.concat
      [ start
      , played
      , judging
      , ended
      ]


playedInRound : Maybe Game.Round -> Maybe Int
playedInRound maybeRound =
  let
    calc = (\round -> case round.responses of
      Card.Hidden count -> Just count
      Card.Revealed _ -> Nothing)
  in
    maybeRound `Maybe.andThen` calc

{- Event Constructors -}

playerJoin : Player -> Event
playerJoin player = PlayerJoin player.id

playerReconnect : Player -> Event
playerReconnect player = PlayerReconnect player.id

playerStatus : Player -> Event
playerStatus player = PlayerStatus player.id player.status

playerScore : Player -> Event
playerScore player = PlayerScore player.id player.score

playerLeft : Player -> Event
playerLeft player = PlayerLeft player.id

playerDisconnect : Player -> Event
playerDisconnect player = PlayerDisconnect player.id

roundStart : Game.Round -> Event
roundStart round = RoundStart round.call round.czar
