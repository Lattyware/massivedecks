package massivedecks.lobby

import scala.util.Random

import massivedecks.exceptions.{BadRequestException, ForbiddenException}
import massivedecks.models.{Errors, Player}
import massivedecks.notifications.Notifiers

/**
  * Players in the game.
  */
class Players(notifiers: Notifiers) {

  /**
    * All players that have been in the game.
    */
  var players: List[Player] = List()

  /**
    * Secrets for all the ais in the game.
    */
  var ais: Set[Player.Secret] = Set()

  /**
    * Any players registered as connected to the game.
    */
  var connected: Set[Player.Id] = Set()

  private var secrets: Map[Player.Id, Player.Secret] = Map()
  private var nextId: Int = 0
  private var aiNames: List[String] = Players.aiName :: Random.shuffle(Players.aiNames)
  private var nameIteration = 0

  /**
    * Validate the given secret as valid.
    * @param secret The secret to check.
    * @throws ForbiddenException with key "secret-wrong-or-not-a-player" if the secret is invalid.
    */
  def validateSecret(secret: Player.Secret): Unit = {
    ForbiddenException.verify(secrets.values.exists(s => s == secret), Errors.SecretWrongOrNotAPlayer())
  }

  /**
    * Add a player to the game, marking them as the owner if they are the first player in the game.
    * (Notifies all clients).
    * @param name The name of the new player.
    * @return The secret for the new player.
    * @throws BadRequestException with key "name-in-use" if there is a player in the lobby with the same name.
    */
  def addPlayer(name: String): Player.Secret = {
    BadRequestException.verify(players.forall(player => player.name != name), Errors.NameInUse())
    val id = newId()
    val player = Player(id, name)
    players = players :+ player
    val secret = Player.Secret(id)
    secrets = secrets + (id -> secret)
    notifiers.playerJoin(player)
    secret
  }

  /**
    * Adds an Ai to the game, generating a name for it. (Notifies all clients).
    */
  def addAi(): Unit = {
    val secret = addPlayer(generateAiName())
    updatePlayer(secret.id, setPlayerStatus(Player.Ai, Set()))
    connected += secret.id
    ais += secret
  }

  private def generateAiName(): String = {
    val name :: rest = aiNames
    aiNames = rest
    if (rest.isEmpty) {
      nameIteration += 1
      aiNames = Random.shuffle(Players.aiNames).map(name => name + " " + nameIteration)
    }
    if (players.exists(player => player.name == name)) {
      generateAiName()
    } else {
      name
    }
  }

  /**
    * Update all players using the given updater.
    * Note that you will need to notify clients about the changes if the updater doesn't.
    * @param update The player updater.
    */
  def updatePlayers(update: (Player => Player)): Unit = {
    players = players.map(player => update(player))
  }

  /**
    * Update the given player using the given updater.
    * Note that you will need to notify clients about the changes if the updater doesn't.
    * @param update The player updater.
    * @throws BadRequestException with key "not-a-player" if the player doesn't exist.
    */
  def updatePlayer(playerId: Player.Id, update: (Player => Player)): Unit = {
    val updated = update(getPlayer(playerId))
    players = players.map(player => if (player.id == playerId) updated else player)
  }

  /**
    * Get the given player.
    * @param playerId The ID of the player to get.
    * @return The player.
    * @throws BadRequestException with the key "not-a-player" if the player doesn't exist.
    */
  def getPlayer(playerId: Player.Id): Player = {
    players.find(player => player.id == playerId).getOrElse(throw BadRequestException(Errors.NotAPlayer()))
  }

  /**
    * Mark the given player as back into the game. (Notifies all clients)
    * @param playerId The player to mark as back.
    * @throws BadRequestException with key "not-a-player" if the player doesn't exist.
    * @throws BadRequestException with key "not-being-skipped" if the player was not being skipped.
    */
  def back(playerId: Player.Id): Unit = {
    val player = getPlayer(playerId)
    BadRequestException.verify(player.status == Player.Skipping, Errors.NotBeingSkipped())
    updatePlayer(playerId, setPlayerStatus(Player.Neutral, Player.Status.sticky - Player.Skipping))
  }

  /**
    * Mark the given player as having left the game. (Notifies all clients)
    * @param playerId The player to mark as having left the game.
    * @throws BadRequestException with key "not-a-player" if the player doesn't exist.
    */
  def leave(playerId: Player.Id): Unit = {
    updatePlayer(playerId, setPlayerLeft())
  }

  /**
    * Register the player as connected to the game, and mark them as such. (Notifies all clients)
    * @param playerId The player to mark as connected.
    * @throws BadRequestException with key "already-left-game" if the player is marked as having left the game.
    * @throws BadRequestException with key "not-a-player" if the player doesn't exist.
    */
  def register(playerId: Player.Id): Unit = {
    val player = getPlayer(playerId)
    BadRequestException.verify(!player.left, Errors.AlreadyLeftGame())
    connected += playerId
    updatePlayer(playerId, setPlayerDisconnected(false))
    if (player.status == Player.Skipping) {
      back(playerId)
    }
  }

  /**
    * Remove the registration of the player as connected to the game.
    * @param playerId The player to remove registration for.
    */
  def unregister(playerId: Player.Id): Unit = {
    connected -= playerId
  }

  private def newId() = {
    val id = Player.Id(nextId)
    nextId += 1
    id
  }

  /**
    * Check if the given player can be the card czar (is human, hasn't left, isn't being skipped).
    * @param player The player to check.
    * @return If the player can be the card czar.
    */
  def canBeCzar(player: Player): Boolean = {
    ais.exists(ai => ai.id == player.id) || player.left || player.status == Player.Skipping
  }

  /**
    * @return The ids of every player that has been in the game.
    */
  def ids = players.map(player => player.id)

  /**
    * @return The number of players that have been in the game.
    */
  def amount = players.length

  /**
    * @return Players that are actively in the game (not left or being skipped)
    */
  def activePlayers = players.filter(player => !player.left && player.status != Player.Skipping)

  /**
    * An updater for players that changes their status. See updatePlayers()/updaterPlayer().
    * @param newStatus The status to set the player to.
    * @param ignoring If the player has a status in this set, do not change it. (Defaults to the sticky statuses).
    * @return An updater function for a player. (Notifies all clients)
    */
  def setPlayerStatus(newStatus: Player.Status, ignoring: Set[Player.Status] = Player.Status.sticky): (Player => Player) = {
    player =>
      if (!player.left && !ignoring.contains(player.status) && player.status != newStatus) {
        notifiers.playerStatus(player.id, newStatus)
        player.copy(status = newStatus)
      } else {
        player
      }
  }

  /**
    * An updater for players that changes their score. See updatePlayers()/updaterPlayer().
    * @param by The amount to change the score by.
    * @return An updater function for a player. (Notifies all clients)
    */
  def modifyPlayerScore(by: Int): (Player => Player) = {
    player =>
      val newScore = player.score + by
      notifiers.playerScoreChange(player.id, newScore)
      player.copy(score = newScore)
  }

  /**
    * An updater for players that marks them as having left the game. See updatePlayers()/updaterPlayer().
    * @return An updater function for a player. (Notifies all clients)
    */
  def setPlayerLeft(): (Player => Player) = {
    player =>
      notifiers.playerLeft(player.id)
      if (player.status != Player.Neutral) {
        notifiers.playerStatus(player.id, Player.Neutral)
      }
      player.copy(status = Player.Neutral, left = true)
  }

  /**
    * An updater for players that marks them as being disconnected from the game. See updatePlayers()/updaterPlayer().
    * Note that we generally leave a grace period for clients to reconnect before marking them as disconnected.
    * @param disconnected If the player is connected or disconnected.
    * @return An updater function for a player. (Notifies all clients)
    */
  def setPlayerDisconnected(disconnected: Boolean): (Player => Player) = {
    player =>
      if (!player.left && player.status != Player.Ai) {
        if (disconnected) {
          notifiers.playerDisconnect(player.id)
        } else {
          notifiers.playerReconnect(player.id)
        }
        player.copy(disconnected = disconnected)
      } else {
        player
      }
  }
}
object Players {
  /**
    * The minimum number of players that can be active in a game for it to start or continue.
    */
  val minimum = 2

  /**
    * The name of the first ai.
    */
  val aiName = "Rando Cardrissian"

  /**
    * Names for additional ais.
    */
  val aiNames = List(
    "HAL 9000",
    "GLaDOS",
    "Wheatley",
    "TEC-XX",
    "EDI",
    "343 Guilty Spark",
    "Jarvis",
    "Deep Thought",
    "Gibson",
    "Skynet",
    "AI",
    "Computer",
    "Real Human"
  )
}
