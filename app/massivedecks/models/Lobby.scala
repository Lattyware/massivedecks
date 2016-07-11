package massivedecks.models

import play.api.libs.json.{Format, Json}

import massivedecks.models.Game.Formatters._
import massivedecks.models.Player.Formatters._

/**
  * Created by gareth on 30/06/16.
  */
object Lobby {

  case class Lobby(gameCode: String, config: Game.Config, players: List[Player], round: Option[Game.Round])

  case class LobbyAndHand(lobby: Lobby, hand: Game.Hand)

  object Formatters {
    implicit val lobbyFormat: Format[Lobby] = Json.format[Lobby]
    implicit val lobbyAndHandFormat: Format[LobbyAndHand] = Json.format[LobbyAndHand]
  }

}
