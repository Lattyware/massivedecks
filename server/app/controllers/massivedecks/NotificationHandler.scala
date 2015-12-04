package controllers.massivedecks

import akka.actor.{Actor, ActorRef, Props}
import controllers.massivedecks.game.Actions.Lobby.{Unregister, Register}
import controllers.massivedecks.game.Actions.Store.LobbyAction
import models.massivedecks.Player.Secret
import play.api.libs.json.Json

import models.massivedecks.Player.Formatters._

class NotificationHandler(val lobbyId: String, val store: ActorRef, val out: ActorRef) extends Actor {
  var secret: Option[Secret] = None

  override def receive = {
    case message: String =>
      secret = Json.parse(message).validate[Secret].asOpt
      if (secret.isDefined)
      {
        store ! LobbyAction(lobbyId, Register(secret.get, out))
      }
  }

  override def postStop(): Unit = {
    if (secret.isDefined) {
      store ! LobbyAction(lobbyId, Unregister(secret.get, out))
    }
  }
}
object NotificationHandler {
  def props(lobbyId: String, store: ActorRef, out: ActorRef) = Props(new NotificationHandler(lobbyId, store, out))
}
