package controllers.massivedecks.game

import java.util.UUID
import javax.inject.Inject

import scala.util.Random

import akka.actor.ActorRef
import com.google.inject.assistedinject.Assisted
import controllers.massivedecks.cardcast.{CardCastAPI, CardCastDeck}
import models.massivedecks.Game._
import models.massivedecks.Lobby.{LobbyAndHand, Lobby}
import models.massivedecks.Player._
import play.api.libs.json.Json

import models.massivedecks.Lobby.Formatters._

class State @Inject()(private val cardCast: CardCastAPI, @Assisted val id: String) {
  private var decks: Set[CardCastDeck] = Set()
  private var players: List[Player] = List()
  private var lastPlayerId: Int = -1
  private var secrets: Map[Id, Secret] = Map()
  private var game: Option[GameState] = None
  private var playedInRound: Map[Id, Option[List[Response]]] = Map()
  private var playedOrder: Option[List[Id]] = None
  private var notifications: List[ActorRef] = List()
  private var czarIndex: Int = 0

  def config = Config(decks.map(deck => deck.id).toList)
  def lobby = Lobby(id, config, players, game.map(game => game.round))

  def newPlayer(name: String): Secret = {
    require(players.forall(player => player.name != name), "The name is already in use.")
    lastPlayerId += 1
    val id = Id(lastPlayerId)
    players = players ++ List(Player(id, name, Disconnected, 0))
    val secret = Secret(id, UUID.randomUUID().toString)
    secrets += (id -> secret)
    if (game.isDefined) {
      val state = game.get
      var hands = state.hands
      hands += (id -> Hand(state.deck.drawResponses(Hand.size)))
      game = Some(state.copy(hands=hands))
    }
    sendNotifications()
    secret
  }

  def addDeck(secret: Secret, deckId: String): Unit = {
    validateSecretAndGetId(secret)
    decks = decks + cardCast.deck(deckId)
    sendNotifications()
  }

  def newGame(secret: Secret): Unit = {
    if (players.length < State.minimumPlayers) {
      throw new IllegalStateException(s"You need a minimum of ${State.minimumPlayers} to start a game.")
    }
    val deck = Deck(decks)
    val hands = (for (player <- players) yield player.id -> Hand(deck.drawResponses(Hand.size))).toMap
    game = Some(GameState(deck, hands, nextCzar()))
    beginRound()
    sendNotifications()
  }

  private val statusNotInRound: Set[Status] = Set(Left, Czar)

  def beginRound() = {
    val czar = game.get.round.czar
    setPlayerStatus(czar, Czar)
    playedInRound = (for (player <- players if !statusNotInRound.contains(player.status)) yield player.id -> None).toMap
  }

  def lobbyAndHand(secret: Secret): LobbyAndHand = {
    val id = validateSecretAndGetId(secret)
    val hand = game match {
      case Some(state) =>
        state.hands(id)

      case None =>
        Hand(List())
    }
    LobbyAndHand(lobby, hand)
  }

  def getHand(secret: Secret): Hand = {
    val id = validateSecretAndGetId(secret)
    val state = validateInGameAndGetState()
    state.hands(id)
  }

  def play(secret: Secret, ids: List[Int]): Unit = {
    val id = validateSecretAndGetId(secret)
    val state = validateInGameAndGetState()
    require (playedInRound.get(id).isDefined, "You can't play into this round.")
    if (playedInRound(id).isDefined) {
      throw new IllegalStateException("Already played into this round.")
    }
    val round = state.round
    if (round.responses.cards.isDefined) {
      throw new IllegalStateException("Already judging this round, can't play into it.")
    }
    require(ids.length == state.round.call.slots,
      s"Wrong number of cards played (got ${ids.length}, expected ${state.round.call.slots}).")
    val hand = state.hands(id).hand
    val toPlay: List[Response] = ids.map(hand)
    val newHand = Hand(hand.filter(response => !toPlay.contains(response)) ++ state.deck.drawResponses(toPlay.length))
    var hands = state.hands
    hands += (id -> newHand)
    playedInRound += (id -> Some(toPlay))
    setPlayerStatus(id, Played)
    game = Some(state.copy(
      round = round.copy(responses=Responses.count(numberOfPlayersWhoHavePlayed)),
      hands = hands
    ))
    if (numberOfPlayersInRound == numberOfPlayersWhoHavePlayed) {
      beginJudging()
    }
    sendNotifications()
  }

  def choose(secret: Secret, winner: Int): Unit = {
    val id = validateSecretAndGetId(secret)
    val state = validateInGameAndGetState()
    require(id == state.round.czar, "Only the current Czar can pick a winner.")
    val winnerId = playedOrder.get.apply(winner)
    players = players.map(player => if (player.id == winnerId) {
      player.copy(score = player.score + 1)
    } else {
      player
    })
    advanceRound()
    sendNotifications()
  }

  def sendNotifications(): Unit = {
    for (socket <- notifications) {
      socket ! Json.toJson(lobby).toString()
    }
  }

  def register(secret: Secret, socket: ActorRef): Unit = {
    val id = validateSecretAndGetId(secret)
    setPlayerStatus(id, playerStatusIfConnected(id), force=true)
    notifications = socket :: notifications
    sendNotifications()
  }

  def unregister(secret: Secret, socket: ActorRef): Unit = {
    val id = validateSecretAndGetId(secret)
    setPlayerStatus(id, Disconnected)
    notifications.filter(s => s != socket)
    sendNotifications()
  }

  private def playerForId(id: Id): Player = players.find(item => item.id == id).get

  private def nextCzar(): Id = {
    if (czarIndex >= players.length) {
      czarIndex = 0
    }
    val playerId = players(czarIndex).id
    czarIndex += 1
    playerId
  }

  private def playerStatusIfConnected(id: Id): Status = {
    val player = playerForId(id)
    if (player.status == Left) { Left } else {
      game match {
        case Some(state) =>
          if (state.round.czar == id) {
            Czar
          } else {
            playedInRound.get(id) match {
              case Some(playedState) => if (playedState.isDefined) { Played } else { NotPlayed }
              case None => Neutral
            }
          }
        case None => Neutral
      }
    }
  }

  private def numberOfPlayersInRound = playedInRound.size
  private def numberOfPlayersWhoHavePlayed = playedInRound.values.count(play => play.isDefined)

  private def beginJudging(): Unit = {
    val state = validateInGameAndGetState()
    val shuffled = Random.shuffle(playedInRound)
    playedOrder = Some(shuffled.map(played => played._1).toList)
    game = Some(state.copy(
      round = state.round.copy(responses=Responses.cards(shuffled.flatMap(played => played._2).toList)),
      hands = state.hands
    ))
  }

  private def advanceRound(): Unit = {
    playedOrder = None
    playedInRound = Map()
    val state = validateInGameAndGetState()
    game = Some(state.copy(round = Round(nextCzar(), state.deck.drawCall(), Responses.count(0))))
    for (player <- players) {
      setPlayerStatus(player.id, NotPlayed)
    }
    beginRound()
  }

  private val stickyStatus: Set[Status] = Set(Disconnected, Left)

  private def setPlayerStatus(id: Id, status: Status, force: Boolean = false): Unit =
    players = players.map(player => if (player.id == id) {
      if (force || !stickyStatus.contains(player.status)) {
        player.copy(status = status)
      } else {
        player
      }
    } else {
      player
    })

  private def validateInGameAndGetState(): GameState = game match {
    case Some(state) => state
    case None => throw new IllegalStateException("No game in progress.")
  }

  private def validateSecretAndGetId(secret: Secret): Id = {
    val id = secret.id
    require(secrets.get(id).map(expected => expected.id).contains(id),
      "Secret was wrong or player doesn't exist.")
    id
  }

  private case class GameState(var deck: Deck, var hands: Map[Id, Hand], var round: Round)
  private object GameState {
    def apply(deck: Deck, hands: Map[Id, Hand], initialCzar: Id): GameState =
      new GameState(deck, hands, Round(initialCzar, deck.drawCall(), Responses.count(0)))
  }
}
object State {
  val minimumPlayers: Int = 2

  trait Factory {
    def apply(id: String): State
  }
}
