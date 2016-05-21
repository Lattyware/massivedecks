package controllers.massivedecks.lobby

import javax.inject.Inject

import scala.concurrent.{Await, ExecutionContext, Future, Promise}
import scala.concurrent.duration._
import scala.util.Try

import controllers.massivedecks.cardcast.{CardcastAPI, CardcastDeck}
import controllers.massivedecks.exceptions.BadRequestException
import controllers.massivedecks.exceptions.BadRequestException._
import controllers.massivedecks.util.ExtraIteratee
import models.massivedecks.Game.Hand
import models.massivedecks.Lobby.Formatters._
import models.massivedecks.Lobby.{LobbyAndHand, Lobby => LobbyModel}
import models.massivedecks.Player
import models.massivedecks.Player.Formatters._
import models.massivedecks.Player.Id
import play.api.libs.iteratee.{Concurrent, Enumerator, Iteratee}
import play.api.libs.json.Json

object Lobby {
  class LobbyFactory @Inject() (cardcast: CardcastAPI) (implicit context: ExecutionContext) {
    def build(gameCode: String) = new Lobby(cardcast, gameCode)
  }

  val disconnectGracePeriod: FiniteDuration = 5.seconds

  def wait(duration: FiniteDuration): Try[Future[Nothing]] = Try(Await.ready(Promise().future, duration))
}
class Lobby(cardcast: CardcastAPI, gameCode: String)(implicit context: ExecutionContext) {

  var config = new Config()
  var game: Option[Game] = None
  val players: Players = new Players()
  val (notificationsEnumerator, notificationsChannel) = Concurrent.broadcast[String]

  def lobby = LobbyModel(gameCode, config.config, players.players, game.map(game => game.round))

  def newPlayer(name: String): Player.Secret = {
    val secret = players.addPlayer(name)
    if (game.isDefined) {
      game.get.addPlayer(secret.id)
    }
    sendNotifications()
    setPlayerDisconnectedAfterGracePeriod(secret.id)
    secret
  }

  def addDeck(secret: Player.Secret, playCode: String): Unit = {
    players.validateSecret(secret)
    Try(Await.ready(cardcast.deck(playCode).andThen { case deck =>
      config.addDeck(deck.get)
      sendNotifications()
    }, Duration.Inf))
  }

  def newAi(secret: Player.Secret): Unit = {
    players.validateSecret(secret)
    players.addAi()
    sendNotifications()
  }

  def newGame(secret: Player.Secret): Unit = {
    if (game.isDefined) {
      throw BadRequestException.json("game-in-progress")
    }
    val current = new Game(players, config)
    game = Some(current)
    beginRound()
    sendNotifications()
  }

  def play(secret: Player.Secret, cardIds: List[String]): Unit = {
    players.validateSecret(secret)
    validateInGame().play(secret.id, cardIds)
    sendNotifications()
  }

  def choose(secret: Player.Secret, winner: Int): Unit = {
    players.validateSecret(secret)
    val game = validateInGame()
    game.choose(secret.id, winner)
    sendNotifications()
    game.beginRound()
    sendNotifications()
  }

  def getHand(secret: Player.Secret): Hand = {
    players.validateSecret(secret)
    validateInGame().getHand(secret.id)
  }

  def getLobbyAndHand(secret: Player.Secret): LobbyAndHand = {
    players.validateSecret(secret)
    val hand = game match {
      case Some(_) =>
        getHand(secret)
      case None =>
        Hand(List())
    }
    LobbyAndHand(lobby, hand)
  }

  def leave(secret: Player.Secret): Unit = {
    players.validateSecret(secret)
    players.updatePlayer(secret.id, player => player.copy(left = true))
    game match {
      case Some(current) => current.playerLeft(secret.id)
      case None =>
    }
    if (players.amount < Players.minimum) {
      game = None
    }
    sendNotifications()
  }

  def skip(secret: Player.Secret, playerIds: Set[Player.Id]): Unit = {
    players.validateSecret(secret)
    verify((players.activePlayers.length - playerIds.size) > Players.minimum, "not-enough-players-to-skip")
    verify(players.players.filter(player => playerIds.contains(player.id)).forall(player => player.disconnected), "players-must-be-skippable")
    validateInGame().skip(secret.id, playerIds)
    sendNotifications()
  }

  def back(secret: Player.Secret): Unit = {
    players.validateSecret(secret)
    players.back(secret.id)
    sendNotifications()
  }

  def redraw(secret: Player.Secret): Unit = {
    players.validateSecret(secret)
    verify(config.houseRules.contains("reboot"), "rule-not-enabled")
    validateInGame().redraw(secret.id)
  }

  def enableRule(secret: Player.Secret, rule: String): Unit = {
    players.validateSecret(secret)
    config.addHouseRule(rule)
    sendNotifications()
  }

  def disableRule(secret: Player.Secret, rule: String): Unit = {
    players.validateSecret(secret)
    config.removeHouseRule(rule)
    sendNotifications()
  }

  def register(): (Iteratee[String, Unit], Enumerator[String]) = {
    (ExtraIteratee.onFirstGivingWhenDone(registerInternal), notificationsEnumerator)
  }

  private def registerInternal(rawSecret: String): () => Unit = {
    val secret = Json.parse(rawSecret).validate[Player.Secret].get
    players.validateSecret(secret)
    players.register(secret.id)
    sendNotifications()
    unregister(secret)
  }

  private def unregister(secret: Player.Secret)(): Unit = {
    players.validateSecret(secret)
    players.unregister(secret.id)
    setPlayerDisconnectedAfterGracePeriod(secret.id)
    sendNotifications()
  }

  private def setPlayerDisconnectedAfterGracePeriod(playerId: Id) = {
    Future {
      Lobby.wait(Lobby.disconnectGracePeriod)
      if (!players.connected.contains(playerId)) {
        players.updatePlayer(playerId, player => player.copy(disconnected = true))
        sendNotifications()
      }
    }
  }

  private def beginRound() = {
    val game = validateInGame()
    game.beginRound()
  }

  private def validateInGame(): Game = game match {
    case Some(state) => state
    case None => throw BadRequestException.json("no-game-in-progress")
  }

  private def sendNotifications(): Unit = notificationsChannel.push(notification())

  private def notification(): String = Json.toJson(lobby).toString()

}
