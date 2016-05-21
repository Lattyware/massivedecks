package controllers.massivedecks

import javax.inject.Inject

import controllers.massivedecks.exceptions.NotFoundException
import controllers.massivedecks.lobby.Lobby
import controllers.massivedecks.lobby.Lobby.LobbyFactory
import org.hashids.Hashids

case class InMemoryStore @Inject() (lobbyFactory: LobbyFactory) extends LobbyStore {
  var currentGameCode: Long = 0
  val gameCodeEncoder = Hashids.reference("massivedecks", 0, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
  var lobbies: Map[String, Lobby] = Map()

  override def newLobby(): Lobby = {
    val gameCode = gameCodeEncoder.encode(currentGameCode)
    val lobby = lobbyFactory.build(gameCode)
    lobbies += (gameCode -> lobby)
    lobby
  }

  override def getLobby(gameCode: String): Lobby = lobbies.get(gameCode) match {
    case Some(lobby) => lobby
    case None => throw NotFoundException.json("lobby-not-found")
  }
}
