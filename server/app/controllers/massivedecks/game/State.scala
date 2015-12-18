package controllers.massivedecks.game

import java.util.UUID
import javax.inject.Inject

import scala.concurrent.{ExecutionContext, Future}
import scala.util.Random
import scala.concurrent.duration._

import akka.pattern.after
import akka.actor.ActorRef
import com.google.inject.assistedinject.Assisted
import controllers.massivedecks.cardcast.{CardCastAPI, CardCastDeck}
import models.massivedecks.Game._
import models.massivedecks.Lobby.Formatters._
import models.massivedecks.Lobby.{Lobby, LobbyAndHand}
import models.massivedecks.Player._
import play.api.libs.concurrent.Akka
import play.api.libs.json.Json
import play.api.Play.current

class State @Inject()(private val cardCast: CardCastAPI, @Assisted val id: String)(implicit ec: ExecutionContext) {
  private var decks: Set[CardCastDeck] = Set()
  private var players: List[Player] = List()
  private var lastPlayerId: Int = -1
  private var secrets: Map[Id, Secret] = Map()
  private var game: Option[GameState] = None
  private var playedInRound: Map[Id, Option[List[Response]]] = Map()
  private var playedOrder: Option[List[Id]] = None
  private var notifications: List[ActorRef] = List()
  private var czarIndex: Int = 0
  private var history: List[Round] = List()
  private var ais: Set[Secret] = Set()
  private var connected: Set[Id] = Set()

  def config = Config(decks.map(deck => deck.info).toList)
  def lobby = Lobby(id, config, players, game.map(game => game.round))

  def newAi(): Unit = {
    val baseName = "Rando Cardrissian"
    var i = 1
    var name = baseName
    while (players.exists(player => player.name == name)) {
      i += 1
      name = baseName + " " + i.toString
    }
    val secret = newPlayer(name)
    setPlayerStatus(secret.id, Ai, force=true)
    connected += secret.id
    ais += secret
    sendNotifications()
  }

  private def setPlayerDisconnectedAfterGracePeriod(id: Id) = {
    after(State.disconnectGracePeriod, using=Akka.system.scheduler)(Future {
      if (setPlayerDisconnected(id, !connected.contains(id))) {
        sendNotifications()
      }
    })
  }

  def newPlayer(name: String): Secret = {
    require(players.forall(player => player.name != name), "The name is already in use.")
    lastPlayerId += 1
    val id = Id(lastPlayerId)
    players = players ++ List(Player(id, name, Neutral, 0, disconnected=false, left=false))
    setPlayerDisconnectedAfterGracePeriod(id)
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

  def retrieveDeck(secret: Secret, deckId: String): Future[CardCastDeck] = {
    validateSecretAndGetId(secret)
    cardCast.deck(deckId)
  }

  def addDeck(secret: Secret, deck: CardCastDeck): Unit = {
    validateSecretAndGetId(secret)
    decks = decks + deck
    sendNotifications()
  }

  def newGame(secret: Secret): Unit = {
    if (numberOfPlayers < State.minimumPlayers) {
      throw new IllegalStateException(s"You need a minimum of ${State.minimumPlayers} to start a game.")
    }
    if (game.isDefined) {
      throw new IllegalStateException(s"A game is already in progress.")
    }
    val deck = Deck(decks)
    val hands = (for (player <- players) yield player.id -> Hand(deck.drawResponses(Hand.size))).toMap
    game = Some(GameState(deck, hands, nextCzar()))
    beginRound()
    sendNotifications()
  }

  private val statusNotInRound: Set[Status] = Set(Skipping, Czar)

  def beginRound() = {
    for (player <- players) {
      setPlayerStatus(player.id, NotPlayed)
    }
    val round = game.get.round
    val czar = round.czar
    setPlayerStatus(czar, Czar)
    playedInRound = (for (player <- players if !statusNotInRound.contains(player.status) && !player.left)
      yield player.id -> None).toMap
    val firstSlots = (0 until round.call.slots).toList
    for (ai <- ais) {
      play(ai, firstSlots)
    }
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
    if (round.responses.revealed.isDefined) {
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
      round = round.copy(responses=Responses.hidden(numberOfPlayersWhoHavePlayed)),
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
    val round = state.round
    val revealed = round.responses.revealed.get
    val wonRound = round.copy(responses=Responses.revealed(revealed.copy(playedByAndWinner=
      Some(PlayedByAndWinner(playedOrder.get, winnerId)))))
    game = Some(state.copy(round=wonRound))
    history = wonRound :: history
    sendNotifications()
    advanceRound()
    sendNotifications()
  }

  def leave(secret: Secret): Unit = {
    val id = validateSecretAndGetId(secret)
    setPlayerLeft(id, left=true)
    playedInRound = playedInRound.filterKeys(pId => pId != id)
    if (numberOfPlayers < State.minimumPlayers) {
      endGame()
    }
    game match {
      case Some(state) =>
        if (state.round.czar == id) {
          invalidateRound()
        } else {
          if (numberOfPlayersInRound == numberOfPlayersWhoHavePlayed) {
            beginJudging()
          }
        }
      case None =>
    }
    sendNotifications()
  }

  def skip(secret: Secret, players: List[Id]): Unit = {
    validateSecretAndGetId(secret)
    require((numberOfPlayers - players.length) > State.minimumPlayers, "Not enough players to skip.")
    for (id <- players) {
      setPlayerStatus(id, Skipping)
      playedInRound = playedInRound.filterKeys(pId => pId != id)
    }
    game match {
      case Some(state) =>
        if (players.contains(state.round.czar)) {
          invalidateRound()
        } else {
          if (numberOfPlayersInRound == numberOfPlayersWhoHavePlayed) {
            beginJudging()
          }
        }
      case None =>
    }
    sendNotifications()
  }

  def back(secret: Secret): Unit = {
    val id = validateSecretAndGetId(secret)
    val player = playerForId(id)
    require(player.status == Skipping, "You are not being skipped.")
    setPlayerStatus(id, Neutral, force=true)
    sendNotifications()
  }

  def register(secret: Secret, socket: ActorRef): Unit = {
    val id = validateSecretAndGetId(secret)
    val player = playerForId(id)
    require(!player.left, "You have left this game.")
    setPlayerDisconnected(id, disconnected=false)
    connected += id
    if (player.status == Skipping) {
      back(secret)
    }
    notifications = socket :: notifications
    sendNotifications()
  }

  def unregister(secret: Secret, socket: ActorRef): Unit = {
    val id = validateSecretAndGetId(secret)
    connected -= id
    setPlayerDisconnectedAfterGracePeriod(id)
    notifications.filter(s => s != socket)
    sendNotifications()
  }

  private def endGame(): Unit = {
    playedOrder = None
    playedInRound = Map()
    game = None
    czarIndex = 0
  }

  private def invalidateRound(): Unit = {
    advanceRound()
  }

  private def sendNotifications(): Unit = {
    for (socket <- notifications) {
      socket ! Json.toJson(lobby).toString()
    }
  }

  private def playerForId(id: Id): Player = players.find(item => item.id == id).get

  private def nextCzar(): Id = {
    if (czarIndex >= players.length) {
      czarIndex = 0
    }
    val player = players(czarIndex)
    val playerId = player.id
    czarIndex += 1
    if (ais.exists(ai => ai.id == playerId) || player.left || player.status == Skipping) {
      nextCzar()
    } else {
      playerId
    }
  }

  private def numberOfPlayers = players.count(player => !player.left)
  private def numberOfPlayersInRound = playedInRound.size
  private def numberOfPlayersWhoHavePlayed = playedInRound.values.count(play => play.isDefined)

  private def beginJudging(): Unit = {
    val state = validateInGameAndGetState()
    val shuffled = Random.shuffle(playedInRound)
    playedOrder = Some(shuffled.map(played => played._1).toList)
    game = Some(state.copy(
      round = state.round.copy(responses=Responses.revealed(Revealed(shuffled.flatMap(played => played._2).toList, None))),
      hands = state.hands
    ))
  }

  private def advanceRound(): Unit = {
    val state = validateInGameAndGetState()
    playedOrder = None
    playedInRound = Map()
    game = Some(state.copy(round = Round(nextCzar(), state.deck.drawCall(), Responses.hidden(0))))
    beginRound()
  }

  private val stickyStatus: Set[Status] = Set(Ai, Skipping)

  private def setPlayerStatus(id: Id, status: Status, force: Boolean = false): Unit = {
    if (!playerForId(id).left) {
      players = players.map(player =>
        if (player.id == id && (force || !stickyStatus.contains(player.status))) {
          player.copy(status = status)
        } else {
          player
        })
    }
  }

  private def setPlayerDisconnected(id: Id, disconnected: Boolean): Boolean = {
    var changed = false
    players = players.map(player =>
      if (player.id == id) {
        changed = true
        player.copy(disconnected=disconnected)
      } else {
        player
      })
    changed
  }

  private def setPlayerLeft(id: Id, left: Boolean): Unit = {
    players = players.map(player =>
      if (player.id == id) {
        player.copy(status=Neutral, left=left)
      } else {
        player
      })
  }

  private def validateInGameAndGetState(): GameState = game match {
    case Some(state) => state
    case None => throw new IllegalStateException("No game in progress.")
  }

  private def validateSecretAndGetId(secret: Secret): Id = {
    val id = secret.id
    require(secrets.get(id).map(expected => expected.secret).contains(secret.secret),
      "Secret was wrong or player doesn't exist.")
    id
  }

  private case class GameState(var deck: Deck, var hands: Map[Id, Hand], var round: Round)
  private object GameState {
    def apply(deck: Deck, hands: Map[Id, Hand], initialCzar: Id): GameState =
      new GameState(deck, hands, Round(initialCzar, deck.drawCall(), Responses.hidden(0)))
  }
}
object State {
  val minimumPlayers: Int = 2
  val disconnectGracePeriod: FiniteDuration = 5.seconds

  trait Factory {
    def apply(id: String): State
  }
}
