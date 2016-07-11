package massivedecks.stores

import java.util.concurrent.atomic.AtomicLong
import javax.inject.Inject

import massivedecks.lobby.Lobby
import play.api.cache.CacheApi

case class InMemoryStore @Inject() (lobbyFactory: Lobby.Factory, cache: CacheApi) extends CachedStore {
  override protected val gameCodeManager: GameCodeManager = new GameCodeManager(new AtomicLong(0))

  private var lobbies: Map[String, Lobby] = Map()

  /**
    * Save the lobby into storage - overwriting existing ones if found.
    *
    * @param lobby The lobby to save.
    */
  override protected def storeLobby(lobby: Lobby): Unit = lobbies += lobby.gameCode -> lobby

  /**
    * Get the lobby for the given game code, or None if it doesn't exist.
    *
    * @param gameCode The game code for the lobby.
    * @return The lobby or None.
    */
  override protected def getLobby(gameCode: String): Option[Lobby] = lobbies.get(gameCode)

  /**
    * Remove the given lobby from storage.
    *
    * @param gameCode The game code for the lobby.
    */
  override def removeLobby(gameCode: String): Unit = lobbies -= gameCode

}
