package massivedecks.models

import play.api.libs.json.{Json, Writes}
import massivedecks.models.Game.Formatters._
import massivedecks.models.Player.Formatters._

/**
  * Created by gareth on 30/06/16.
  */
object Lobby {

  case class Lobby(gameCode: String, config: Game.Config, players: List[Player], state: Game.State)

  case class LobbyAndHand(lobby: Lobby, hand: Game.Hand)

  object Formatters {
    implicit val lobbyWrites: Writes[Lobby] = Json.writes[Lobby]
    implicit val lobbyAndHandWrites: Writes[LobbyAndHand] = Json.writes[LobbyAndHand]
  }

}
