package models.massivedecks

import models.massivedecks.Game.{Config, Hand, Round}
import play.api.libs.json._

import models.massivedecks.Player.Formatters._
import models.massivedecks.Game.Formatters._

object Lobby {

  case class Lobby(gameCode: String, config: Config, players: List[Player], round: Option[Round])

  case class LobbyAndHand(lobby: Lobby, hand: Hand)

  object Formatters {
    implicit val lobbyFormat: Format[Lobby] = Json.format[Lobby]
    implicit val lobbyAndHandFormat: Format[LobbyAndHand] = Json.format[LobbyAndHand]
  }

}
