package massivedecks.lobby

import javax.inject.Inject

import scala.concurrent.{Await, ExecutionContext, Future}
import scala.concurrent.duration._
import scala.util.{Failure, Success, Try}

import massivedecks.exceptions.{BadRequestException, ForbiddenException, RequestFailedException}
import massivedecks.notifications.Notifiers
import massivedecks.models.{Errors, Player, Game => GameModel, Lobby => LobbyModel}
import massivedecks.models.Game.Formatters._
import massivedecks.models.Lobby.Formatters._
import play.api.libs.iteratee.{Enumerator, Iteratee}
import play.api.libs.json.{JsValue, JsObject, Json}
import massivedecks.Util
import massivedecks.cardcast.CardcastAPI

object Lobby {

  /**
    * Factory for dependency injection.
    */
  class Factory @Inject() (cardcast: CardcastAPI) (implicit context: ExecutionContext) {
    def build(gameCode: String, ownerName: String) = new Lobby(cardcast, gameCode, ownerName)
  }

  /**
    * How long to wait after a player disconnects to allow for them to reconnect without treating them as disconnected.
    */
  val disconnectGracePeriod: FiniteDuration = 5.seconds
  /**
    * How long to wait for calls to Cardcast to complete.
    */
  val cardCastWaitPeriod: FiniteDuration = 10.seconds
}
/**
  * Represents a game lobby.
  *
  * @param cardcast The cardcast api.
  * @param gameCode The game code for the lobby.
  */
class Lobby(cardcast: CardcastAPI, val gameCode: String, ownerName: String)(implicit context: ExecutionContext) {

  /**
    * The game in progress if there is one.
    */
  var game: Option[Game] = None

  /**
    * Notifiers for the lobby.
    */
  val notifiers: Notifiers = new Notifiers()

  /**
    * Configuration for the lobby.
    */
  var config = new Config(notifiers)

  /**
    * The players in the lobby.
    */
  val players: Players = new Players(notifiers)

  def gameState = game match {
    case None => GameModel.State.Configuring()
    case Some(g) => GameModel.State.Playing(g.round)
  }

  val owner = newPlayer(ownerName, None)

  /**
    * @return The model for the lobby.
    */
  def lobby = LobbyModel.Lobby(gameCode, owner.id, config.config, players.players, gameState)

  /**
    * Add a new player to the lobby.
    *
    * @param name The name for the player.
    * @return The secret for the player.
    * @throws BadRequestException with key "name-in-use" if there is a player in the lobby with the same name.
    * @throws ForbiddenException with key "password-wrong" if the password is required and wrong.
    */
  def newPlayer(name: String, password: Option[String]): Player.Secret = {
    ForbiddenException.verify(config.password.isEmpty || config.password == password, Errors.PasswordWrong())
    val secret = players.addPlayer(name)
    if (game.isDefined) {
      game.get.addPlayer(secret.id)
    }
    setPlayerDisconnectedAfterGracePeriod(secret.id)
    secret
  }

  /**
    * Try to add the deck to the lobby.
    *
    * @param secret The secret for the player making the request.
    * @param playCode The cardcast play code for the deck.
    * @return An empty response.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws ForbiddenException with key "not-owner" if the requester is not the owner.
    * @throws RequestFailedException with the key "cardcast-timeout" if the request to cardcast doesn't complete.
    */
  def addDeck(secret: Player.Secret, playCode: String): JsValue = {
    players.validateSecret(secret)
    validateIsOwner(secret)
    Try(Await.ready({
      cardcast.deck(playCode).map { deck =>
        config.addDeck(deck)
      }
    }, Lobby.cardCastWaitPeriod)) match {
      case Success(result) =>
        result.value.get.get
      case Failure(exception) =>
        throw RequestFailedException(Errors.CardcastTimeout())
    }
    EmptyResponse
  }

  /**
    * Add a new ai to the lobby.
    *
    * @param secret The secret of the player making the request.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws ForbiddenException with key "not-owner" if the requester is not the owner.
    */
  def newAi(secret: Player.Secret): Unit = {
    players.validateSecret(secret)
    validateIsOwner(secret)
    players.addAi()
  }

  /**
    * Start a new game in the lobby.
    *
    * @param secret The secret of the player making the request.
    * @return The hand of the player making the request in the new game.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws BadRequestException with the key "game-in-progress" if the game has already started.
    */
  def newGame(secret: Player.Secret): JsValue = {
    players.validateSecret(secret)
    if (game.isDefined) {
      throw BadRequestException(Errors.GameInProgress())
    }
    val current = new Game(players, config, notifiers)
    game = Some(current)
    Json.toJson(getHand(secret))
  }

  /**
    * Play the given cards into the round.
    *
    * @param secret The secret of the player making the request.
    * @param cardIds The ids of the responses to play.
    * @return The hand of the player making the request after the cards have been played and replacements drawn.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws BadRequestException with key "no-game-in-progress" if there is not a game underway.
    * @throws BadRequestException with key "not-in-round" if the player is not in the round.
    * @throws BadRequestException with key "already-played" if the player has already played into the round.
    * @throws BadRequestException with key "already-judging" if the round is already in it's judging state.
    * @throws BadRequestException with key "wrong-number-of-cards-played" if the wrong number of responses were played.
    *                             The value "got" is the number of cards played, the value "expected" is the number
    *                             required for the request to succeed
    * @throws BadRequestException with key "invalid-card-id-given" if any of the card ids are not in the given player's
    *                             hand.
    */
  def play(secret: Player.Secret, cardIds: List[String]): JsValue = {
    players.validateSecret(secret)
    validateInGame().play(secret.id, cardIds)
    Json.toJson(getHand(secret))
  }

  /**
    * Choose the winning play for the round.
    *
    * @param secret The secret of the player making the request.
    * @param winner The index of the played responses being chosen.
    * @return An empty response.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws BadRequestException with key "no-game-in-progress" if there is not a game underway.
    * @throws BadRequestException with key "not-czar" if the current player is not the czar.
    * @throws BadRequestException with key "not-judging" if the round is not yet in the judging phase.
    * @throws BadRequestException with key "no-such-played-cards" if the index does not exist.
    * @throws BadRequestException with key "already-judged" if the round is already finished.
    */
  def choose(secret: Player.Secret, winner: Int): JsValue = {
    players.validateSecret(secret)
    val game = validateInGame()
    game.choose(secret.id, winner)
    beginRound()
    EmptyResponse
  }

  /**
    * Get the hand of the player.
    *
    * @param secret The secret of the player making the request.
    * @return The hand of the player.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws BadRequestException with key "no-game-in-progress" if there is not a game underway.
    */
  def getHand(secret: Player.Secret): GameModel.Hand = {
    players.validateSecret(secret)
    validateInGame().getHand(secret.id)
  }

  /**
    * @return The history of the current game.
    * @throws BadRequestException with key "no-game-in-progress" if there is not a game underway.
    */
  def gameHistory() : List[GameModel.Round.Finished] = {
    validateInGame().history
  }

  /**
    * Get the lobby and hand models for the lobby.
    *
    * @param secret The secret of the player making the request.
    * @return The lobby and the hand of the player.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    */
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

  /**
    * Mark the given player as having left the game.
    *
    * @param secret The secret of the player making the request.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    */
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

  private def endGame(): Unit = {
    game = None
    players.updatePlayers(players.setPlayerStatus(Player.Neutral))
    notifiers.gameEnd()
  }

  /**
    * Start skipping the given players.
    *
    * @param secret The secret of the player making the request.
    * @param playerIds The players to start skipping.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws BadRequestException with key "no-game-in-progress" if there is not a game underway.
    * @throws BadRequestException with key "not-enough-players" if the game would end by skipping the given
    *                             players.
    * @throws BadRequestException with key "players-must-be-skippable" if the players are not skippable.
    * @return An empty response.
    */
  def skip(secret: Player.Secret, playerIds: Set[Player.Id]): JsValue = {
    players.validateSecret(secret)
    val game = validateInGame()
    BadRequestException.verify((players.activePlayers.length - playerIds.size) >= Players.minimum, Errors.NotEnoughPlayers(Players.minimum))
    val requestedPlayers = players.players.filter(player => playerIds.contains(player.id))
    if (!game.round.state.afterTimeLimit) {
      BadRequestException.verify(requestedPlayers.forall(player => player.disconnected), Errors.PlayersMustBeSkippable())
    } else {
      if (game.round.state.isPlaying) {
        BadRequestException.verify(requestedPlayers.forall(player => player.status == Player.Czar), Errors.PlayersMustBeSkippable())
      } else {
        BadRequestException.verify(requestedPlayers.forall(player => player.status == Player.NotPlayed), Errors.PlayersMustBeSkippable())
      }
    }
    game.skip(secret.id, playerIds)
    EmptyResponse
  }

  /**
    * Mark the given player as back into the game.
    *
    * @param secret The secret of the player making the request.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws BadRequestException with key "not-being-skipped" if the player was not being skipped.
    * @return An empty response.
    */
  def back(secret: Player.Secret): JsValue = {
    players.validateSecret(secret)
    players.back(secret.id)
    EmptyResponse
  }

  /**
    * Redraw the hand of the given player.
    *
    * @param secret The secret of the player making the request.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws BadRequestException with key "rule-not-enabled" if the rule is not enabled.
    * @throws BadRequestException with key "no-game-in-progress" if there is not a game underway.
    * @throws BadRequestException with the key "not-enough-points-to-redraw" if the player doesn't have enough points.
    * @return The hand of the player.
    */
  def redraw(secret: Player.Secret): JsValue = {
    players.validateSecret(secret)
    BadRequestException.verify(config.houseRules.contains("reboot"), Errors.RuleNotEnabled())
    validateInGame().redraw(secret.id)
    Json.toJson(getHand(secret))
  }

  /**
    * Enable the given rule.
    *
    * @param secret The secret of the player making the request.
    * @param rule The rule to enable.
    * @return An empty response.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws ForbiddenException with key "not-owner" if the requester is not the owner.
    */
  def enableRule(secret: Player.Secret, rule: String): JsValue = {
    players.validateSecret(secret)
    validateIsOwner(secret)
    config.addHouseRule(rule)
    EmptyResponse
  }

  /**
    * Set the password
    *
    * @param secret The secret of the player making the request.
    * @param password The password to set, empty means no password.
    * @return An empty response.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws ForbiddenException with key "not-owner" if the requester is not the owner.
    */
  def setPassword(secret: Player.Secret, password: Option[String]): JsValue = {
    players.validateSecret(secret)
    validateIsOwner(secret)
    config.setPassword(password)
    EmptyResponse
  }

  /**
    * Disable the given rule.
    *
    * @param secret The secret of the player making the request.
    * @param rule The rule to disable.
    * @return An empty response.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    * @throws ForbiddenException with key "not-owner" if the requester is not the owner.
    */
  def disableRule(secret: Player.Secret, rule: String): JsValue = {
    players.validateSecret(secret)
    validateIsOwner(secret)
    config.removeHouseRule(rule)
    EmptyResponse
  }

  def EmptyResponse: JsValue = JsObject(Seq())

  /**
    * Register a websocket connection.
    *
    * @return The iteratee and enumerator for the websocket.
    */
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

  private def setPlayerDisconnectedAfterGracePeriod(playerId: Player.Id): Unit = {
    Future {
      Util.wait(Lobby.disconnectGracePeriod)
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
    case None => throw BadRequestException(Errors.NoGameInProgress())
  }

  private def validateIsOwner(secret: Player.Secret) = {
    ForbiddenException.verify(owner == secret, Errors.NotOwner())
  }

}
