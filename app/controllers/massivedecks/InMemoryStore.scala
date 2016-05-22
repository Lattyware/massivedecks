package controllers.massivedecks

import java.util.concurrent.atomic.AtomicLong
import java.util.concurrent.locks.{Lock, ReentrantLock}
import javax.inject.Inject

import controllers.massivedecks.exceptions.NotFoundException
import controllers.massivedecks.lobby.Lobby
import controllers.massivedecks.lobby.Lobby.LobbyFactory
import org.hashids.Hashids

case class InMemoryStore @Inject() (lobbyFactory: LobbyFactory) extends LobbyStore {
  var currentGameCode: AtomicLong = new AtomicLong(0)
  val gameCodeEncoder = Hashids.reference("massivedecks", 0, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
  var lobbies: Map[String, (Lobby, Lock)] = Map()

  override def newLobby(): Lobby = {
    val gameCode = gameCodeEncoder.encode(currentGameCode.incrementAndGet())
    val lobby = lobbyFactory.build(gameCode)
    lobbies += (gameCode -> (lobby, new ReentrantLock()))
    lobby
  }

  override def getLobby(gameCode: String): Lobby = lobbies.get(gameCode) match {
    case Some((lobby, lock)) =>
      lock.lock()
      try {
        lobby
      } finally {
        lock.unlock()
      }

    case None =>
      throw NotFoundException.json("lobby-not-found")
  }
}
