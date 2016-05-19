package controllers.massivedecks.game

import javax.inject.{Inject, Singleton}

import scala.util.Failure

import akka.actor.{ActorRef, Actor}
import Actions.Lobby.GetLobby
import controllers.massivedecks.game.Actions.Store._
import play.api.libs.concurrent.InjectedActorSupport
import org.hashids.Hashids

/**
  * This should really use MapDB so it'll survive restart.
  */
@Singleton()
class Store @Inject() (gameFactory: Game.Factory) extends Actor with InjectedActorSupport {
  private var games: Map[Long, ActorRef] = Map()
  private val hashIds = Hashids.reference("massivedecks", 0, "abcdefghijklmnopqrstuvwxyz0123456789")

  def receive = {
    case NewLobby =>
      val id: Long = games.size
      val gameCode: String = hashIds.encode(id)
      val lobby: ActorRef = injectedChild(gameFactory(gameCode), gameCode)
      games += (id -> lobby)
      lobby.forward(GetLobby)

    case LobbyAction(id, action) => sendActionToLobby(id, action)

    case PlayerAction(id, action) => sendActionToLobby(id, action)
  }

  private def sendActionToLobby(gameCode: String, action: Any): Unit = {
    decodeId(gameCode).flatMap(decodedId => games.get(decodedId)) match {
      case Some(game) => game.forward(action)
      case None => sender() ! Failure(NotFoundException.json("lobby-not-found"))
    }
  }

  private def decodeId(id: String): Option[Long] = hashIds.decode(id.toLowerCase()).headOption
}
