package massivedecks.stores

import massivedecks.lobby.Lobby

/**
  * A lobby store is used to store the game data from lobbies.
  */
trait LobbyStore {

  /**
    * Make a new lobby.
    * @param ownerName The name of the owner (the player making the lobby).
    * @return The game code for the new lobby.
    */
  def newLobby(ownerName: String): String

  /**
    * Perform a read-only action in the lobby.
    * This should lock the lobby so other reads can't happen.
    * @param gameCode The game code for the lobby.
    * @param readAction The action to read from the lobby.
    * @tparam Result The type of the result of the read.
    * @return The result of the read.
    */
  def readFromLobby[Result](gameCode: String)(readAction: Lobby => Result): Result

  /**
    * Perform an action inside the lobby, saving the resulting lobby.
    * This should lock the lobby so other writes and reads can't happen.
    * @param gameCode The game code for the lobby.
    * @param action The action to perform in the lobby.
    * @tparam Result The type of the result of the action.
    * @return The result of the action.
    */
  def performInLobby[Result](gameCode: String)(action: Lobby => Result): Result

  /**
    * Remove the given lobby from storage.
    * @param gameCode The game code for the lobby.
    */
  def removeLobby(gameCode: String): Unit

}
