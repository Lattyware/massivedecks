package controllers.massivedecks.lobby

import scala.util.Random

import controllers.massivedecks.exceptions.BadRequestException
import controllers.massivedecks.exceptions.BadRequestException._
import models.massivedecks.Player

/**
  * Players in the game.
  */
class Players {

  var players: List[Player] = List()
  var ais: Set[Player.Secret] = Set()
  var connected: Set[Player.Id] = Set()
  private var owner: Option[Player.Id] = None
  private var secrets: Map[Player.Id, Player.Secret] = Map()
  private var nextId: Int = 0
  private var aiNames: List[String] = Players.aiName :: Random.shuffle(Players.aiNames)
  private var nameIteration = 0

  def validateSecret(secret: Player.Secret): Unit = {
    verify(secrets.values.exists(s => s == secret), "secret-wrong-or-not-a-player")
  }

  def addPlayer(name: String): Player.Secret = {
    verify(players.forall(player => player.name != name), "name-in-use")
    val id = newId()
    players = players :+ Player(id, name)
    val secret = Player.Secret(id)
    secrets = secrets + (id -> secret)
    secret
  }

  def addAi(): Unit = {
    val secret = addPlayer(generateAiName())
    updatePlayer(secret.id, Players.setPlayerStatus(Player.Ai, Set()))
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

  def updatePlayers(update: (Player => Player)): Unit = {
    players = players.map(player => update(player))
  }

  def updatePlayer(playerId: Player.Id, update: (Player => Player)): Unit = {
    val updated = update(getPlayer(playerId))
    players = players.map(player => if (player.id == playerId) updated else player)
  }

  def getPlayer(playerId: Player.Id): Player = {
    players.find(player => player.id == playerId).getOrElse(throw BadRequestException.json("secret-wrong-or-not-a-player"))
  }

  def back(playerId: Player.Id): Unit = {
    val player = getPlayer(playerId)
    verify(player.status == Player.Skipping, "not-being-skipped")
    updatePlayer(playerId, Players.setPlayerStatus(Player.Neutral, Player.Status.sticky - Player.Skipping))
  }

  def register(playerId: Player.Id): Unit = {
    val player = getPlayer(playerId)
    verify(!player.left, "already-left-game")
    updatePlayer(playerId, player => player.copy(disconnected = false))
    connected += playerId
    if (player.status == Player.Skipping) {
      back(playerId)
    }
  }

  def unregister(playerId: Player.Id): Unit = {
    connected -= playerId
  }

  private def newId() = {
    val id = Player.Id(nextId)
    nextId += 1
    id
  }

  def canBeCzar(player: Player): Boolean = {
    ais.exists(ai => ai.id == player.id) || player.left || player.status == Player.Skipping
  }

  def ids = players.map(player => player.id)

  def amount = players.length

  def activePlayers = players.filter(player => !player.left && player.status != Player.Skipping)

}
object Players {
  def setPlayerStatus(newStatus: Player.Status, ignoring: Set[Player.Status] = Player.Status.sticky): (Player => Player) = {
    player => if (!ignoring.contains(player.status)) player.copy(status = newStatus) else player
  }

  val minimum = 2

  val aiName = "Rando Cardrissian"

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
