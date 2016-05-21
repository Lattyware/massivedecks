package controllers.massivedecks

import controllers.massivedecks.lobby.Lobby

trait LobbyStore {
  def newLobby(): Lobby
  def getLobby(gameCode: String): Lobby
}
