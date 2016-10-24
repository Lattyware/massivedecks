package massivedecks.lobby

import massivedecks.exceptions.{BadRequestException, ForbiddenException}
import massivedecks.models.Player
import massivedecks.notifications.Notifiers
import org.specs2._
import org.specs2.mock.Mockito

/**
  * Specification for the players.
  */
class PlayersSpec extends Specification with Mockito { def is = s2"""

    The players controller should
      Not allow new players with the same name as an existing one $notAllowNewPlayerWithSameNameAsExisting
      Notify all clients when a new player joins                  $notifyAllClientsOnNewPlayer
      Validate a valid secret                                     $validateValidSecret
      Not validate a secret for a player that doesn't exist       $noValidateSecretForNonExistentPlayer
      Not validate a secret where the secret is wrong             $noValidateSecretWhereWrong
      Adding an AI should never result in a name clash            $aiShouldAvoidNameClashes
      Adding an AI should notify all clients                      $aiShouldNotifyAllClients
  """

  val playerName = "Player Name"
  val playerName2 = "Player 2 Name"

  def notAllowNewPlayerWithSameNameAsExisting = {
    val mockNotifiers = mock[Notifiers]
    val players = new Players(mockNotifiers)
    players.addPlayer(playerName)
    players.addPlayer(playerName) must throwA[BadRequestException]
  }

  def notifyAllClientsOnNewPlayer = {
    val mockNotifiers = mock[Notifiers]
    val players = new Players(mockNotifiers)
    val secret = players.addPlayer(playerName)
    there was one(mockNotifiers).playerJoin(players.getPlayer(secret.id))
  }

  def validateValidSecret = {
    val mockNotifiers = mock[Notifiers]
    val players = new Players(mockNotifiers)
    val secret = players.addPlayer(playerName)
    players.validateSecret(secret)
    success
  }

  def noValidateSecretForNonExistentPlayer = {
    val mockNotifiers = mock[Notifiers]
    val players = new Players(mockNotifiers)
    val secret = players.addPlayer(playerName)
    players.validateSecret(Player.Secret(Player.Id(-1), secret.secret)) must throwA[ForbiddenException]
  }

  def noValidateSecretWhereWrong = {
    val mockNotifiers = mock[Notifiers]
    val players = new Players(mockNotifiers)
    val secret = players.addPlayer(playerName)
    players.validateSecret(Player.Secret(secret.id, "wrong")) must throwA[ForbiddenException]
  }

  def aiShouldAvoidNameClashes = {
    val mockNotifiers = mock[Notifiers]
    val players = new Players(mockNotifiers)
    players.addPlayer(Players.aiName)
    for (name <- Players.aiNames) {
      players.addPlayer(name)
    }
    players.addAi()
    players.addAi()
    success
  }

  def aiShouldNotifyAllClients = {
    val mockNotifiers = mock[Notifiers]
    val players = new Players(mockNotifiers)
    val secret = players.addAi()
    there was one(mockNotifiers).playerJoin(Player(Player.Id(0), "Rando Cardrissian", Player.Neutral, 0, disconnected=false, left=false))
    there was one(mockNotifiers).playerStatus(Player.Id(0), Player.Ai)
  }

}
