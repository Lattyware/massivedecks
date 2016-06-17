package controllers.massivedecks

import controllers.massivedecks.lobby.Lobby

trait LobbyStore {
  /**
    * Make a new lobby.
    * @return The lobby.
    */
  def newLobby(): Lobby

  /**
    * Get the lobby with the given game code.
    * @param gameCode The game code.
    * @return The lobby.
    */
  def getLobby(gameCode: String): Lobby
}
