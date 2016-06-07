package controllers.massivedecks.lobby

import javax.inject.Inject

import scala.concurrent.{Await, ExecutionContext, Future, Promise}
import scala.concurrent.duration._
import scala.util.{Failure, Success, Try}

import controllers.massivedecks.cardcast.CardcastAPI
import controllers.massivedecks.exceptions.{BadRequestException, RequestFailedException}
import controllers.massivedecks.notifications.Notifiers
import models.massivedecks.{Game => GameModel}
import models.massivedecks.Game.Formatters._
import models.massivedecks.{Lobby => LobbyModel}
import models.massivedecks.Lobby.Formatters._
import models.massivedecks.Player
import models.massivedecks.Player.Id
import play.api.libs.iteratee.{Enumerator, Iteratee}
import play.api.libs.json.{JsValue, Json}

object Lobby {
  class LobbyFactory @Inject() (cardcast: CardcastAPI) (implicit context: ExecutionContext) {
    def build(gameCode: String) = new Lobby(cardcast, gameCode)
  }

  val disconnectGracePeriod: FiniteDuration = 5.seconds
  val cardCastWaitPeriod: FiniteDuration = 10.seconds

  def wait(duration: FiniteDuration): Try[Future[Nothing]] = Try(Await.ready(Promise().future, duration))
}
class Lobby(cardcast: CardcastAPI, gameCode: String)(implicit context: ExecutionContext) {

  var game: Option[Game] = None
  val notifiers: Notifiers = new Notifiers()
  var config = new Config(notifiers)
  val players: Players = new Players(notifiers)

  def lobby = LobbyModel.Lobby(gameCode, config.config, players.players, game.map(game => game.round))

  def newPlayer(name: String): Player.Secret = {
    val secret = players.addPlayer(name)
    if (game.isDefined) {
      game.get.addPlayer(secret.id)
    }
    setPlayerDisconnectedAfterGracePeriod(secret.id)
    secret
  }

  def addDeck(secret: Player.Secret, playCode: String): JsValue = {
    players.validateSecret(secret)
    Try(Await.ready({
      cardcast.deck(playCode).map { deck =>
        config.addDeck(deck)
      }
    }, Lobby.cardCastWaitPeriod)) match {
      case Success(result) =>
        result.value.get.get
      case Failure(exception) =>
        throw RequestFailedException.json("cardcast-timeout")
    }
    Json.toJson("")
  }

  def newAi(secret: Player.Secret): Unit = {
    players.validateSecret(secret)
    val aiSecret = players.addAi()
  }

  def newGame(secret: Player.Secret): JsValue = {
    if (game.isDefined) {
      throw BadRequestException.json("game-in-progress")
    }
    notifiers.gameStart()
    val current = new Game(players, config, notifiers)
    game = Some(current)
    Json.toJson(getHand(secret))
  }

  def play(secret: Player.Secret, cardIds: List[String]): JsValue = {
    players.validateSecret(secret)
    validateInGame().play(secret.id, cardIds)
    Json.toJson(getHand(secret))
  }

  def choose(secret: Player.Secret, winner: Int): JsValue = {
    players.validateSecret(secret)
    val game = validateInGame()
    game.choose(secret.id, winner)
    beginRound()
    Json.toJson("")
  }

  def getHand(secret: Player.Secret): GameModel.Hand = {
    players.validateSecret(secret)
    validateInGame().getHand(secret.id)
  }

  def gameHistory() : List[GameModel.FinishedRound] = {
    validateInGame().history
  }

  def getLobbyAndHand(secret: Player.Secret): JsValue = {
    players.validateSecret(secret)
    Json.toJson(lobbyAndHand(secret))
  }

  private def lobbyAndHand(secret: Player.Secret): LobbyModel.LobbyAndHand = {
    val hand = game match {
      case Some(_) =>
        getHand(secret)
      case None =>
        GameModel.Hand(List())
    }
    LobbyModel.LobbyAndHand(lobby, hand)
  }

  def leave(secret: Player.Secret): Unit = {
    players.validateSecret(secret)
    players.leave(secret.id)
    game.foreach { current =>
      if (players.activePlayers.length < Players.minimum) {
        endGame()
      }
      current.playerLeft(secret.id)
    }
  }

  def endGame(): Unit = {
    game = None
    players.updatePlayers(players.setPlayerStatus(Player.Neutral))
    notifiers.gameEnd()
  }

  def skip(secret: Player.Secret, playerIds: Set[Player.Id]): JsValue = {
    players.validateSecret(secret)
    BadRequestException.verify((players.activePlayers.length - playerIds.size) >= Players.minimum, "not-enough-players-to-skip")
    BadRequestException.verify(players.players.filter(player => playerIds.contains(player.id)).forall(player => player.disconnected), "players-must-be-skippable")
    val game = validateInGame()
    game.skip(secret.id, playerIds)
    Json.toJson("")
  }

  def back(secret: Player.Secret): JsValue = {
    players.validateSecret(secret)
    players.back(secret.id)
    Json.toJson("")
  }

  def redraw(secret: Player.Secret): JsValue = {
    players.validateSecret(secret)
    BadRequestException.verify(config.houseRules.contains("reboot"), "rule-not-enabled")
    validateInGame().redraw(secret.id)
    Json.toJson(getHand(secret))
  }

  def enableRule(secret: Player.Secret, rule: String): JsValue = {
    players.validateSecret(secret)
    config.addHouseRule(rule)
    Json.toJson("")
  }

  def disableRule(secret: Player.Secret, rule: String): JsValue = {
    players.validateSecret(secret)
    config.removeHouseRule(rule)
    Json.toJson("")
  }

  def register(): (Iteratee[String, Unit], Enumerator[String]) = {
    notifiers.openedSocket(register, unregister)
  }

  private def register(secret: Player.Secret): LobbyModel.LobbyAndHand = {
    players.validateSecret(secret)
    players.register(secret.id)
    lobbyAndHand(secret)
  }

  private def unregister(playerId: Player.Id): Unit = {
    players.unregister(playerId)
    setPlayerDisconnectedAfterGracePeriod(playerId)
  }

  private def setPlayerDisconnectedAfterGracePeriod(playerId: Id): Unit = {
    Future {
      Lobby.wait(Lobby.disconnectGracePeriod)
      if (!players.connected.contains(playerId)) {
        players.updatePlayer(playerId, players.setPlayerDisconnected(true))
      }
    }
  }

  private def beginRound(): Unit = {
    val game = validateInGame()
    game.beginRound()
  }

  private def validateInGame(): Game = game match {
    case Some(state) => state
    case None => throw BadRequestException.json("no-game-in-progress")
  }

}
