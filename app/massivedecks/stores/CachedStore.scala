package massivedecks.stores

import scala.concurrent.duration._
import java.util.concurrent.locks.{Lock, ReentrantLock}

import massivedecks.exceptions.NotFoundException
import massivedecks.lobby.Lobby
import massivedecks.models.Errors
import play.api.cache.CacheApi

/**
  * This trait provides a framework for a LobbyStore with caching and locking.
  */
trait CachedStore extends LobbyStore {

  protected val lobbyFactory: Lobby.Factory
  protected val gameCodeManager: GameCodeManager
  protected val cache: CacheApi

  protected var locks: Map[String, Lock] = Map()

  /**
    * Get the lobby for the given game code, or None if it doesn't exist.
    *
    * @param gameCode The game code for the lobby.
    * @return The lobby or None.
    */
  protected def getLobby(gameCode: String): Option[Lobby]

  /**
    * Save the lobby into storage - overwriting existing ones if found.
    *
    * @param lobby The lobby to save.
    */
  protected def storeLobby(lobby: Lobby): Unit

  override def newLobby(ownerName: String): String = {
    val gameCode = gameCodeManager.generate()
    val lock = lockFor(gameCode)
    try {
      val lobby = lobbyFactory.build(gameCode, ownerName)
      saveLobby(lobby)
    } finally {
      lock.unlock()
    }
    gameCode
  }

  private def saveLobby(lobby: Lobby): Unit = {
    cache.set(lobby.gameCode, lobby, CachedStore.cacheTimeout)
    storeLobby(lobby)
  }

  override def readFromLobby[Result](gameCode: String)(readAction: Lobby => Result): Result =
    performInLobby(gameCode)(readAction)

  override def performInLobby[Result](gameCode: String)(action: Lobby => Result): Result = {
    val lock = lockFor(gameCode)
    cache.get(gameCode).orElse { getLobby(gameCode) } match {
      case Some(lobby) =>
        try {
          try {
            action(lobby)
          } finally {
            saveLobby(lobby)
          }
        } finally {
          lock.unlock()
        }

      case None =>
        lock.unlock()
        throw NotFoundException(Errors.LobbyNotFound())
    }
  }

  private def lockFor(gameCode: String): Lock = {
    locks.get(gameCode) match {
      case Some(lock) =>
        lock.lock()
        lock

      case None =>
        val lock = new ReentrantLock()
        lock.lock()
        locks += gameCode -> lock
        lock
    }
  }

}
object CachedStore {

  /**
    * How long after being saved lobbies will fall out of the cache.
    */
  val cacheTimeout = 1.minutes

}
