package controllers.massivedecks.game

import javax.inject.Inject

import scala.util.Try

import akka.actor.Actor
import com.google.inject.assistedinject.Assisted
import Actions.Lobby._
import controllers.massivedecks.game.Actions.Player.{GetHand, NewPlayer}
import play.api.libs.json.Json

import models.massivedecks.Lobby.Formatters._
import models.massivedecks.Player.Formatters._
import models.massivedecks.Game.Formatters._

class Game @Inject()(private val state: State, @Assisted private val id: String) extends Actor {
  def receive = {
    case message @ _ => doReceive(message)
  }

  def doReceive(message: Any) = {
    sender() ! Try(message match {
      case GetLobby =>
        Json.toJson(state.lobby)

      case AddDeck(secret, deckId) =>
        state.addDeck(secret, deckId)
        Json.toJson(state.lobbyAndHand(secret))

      case NewGame(secret) =>
        state.newGame(secret)
        Json.toJson(state.lobbyAndHand(secret))

      case Play(secret, ids) =>
        state.play(secret, ids)
        Json.toJson(state.lobbyAndHand(secret))

      case Choose(secret, winner) =>
        state.choose(secret, winner)
        Json.toJson(state.lobbyAndHand(secret))

      case NewPlayer(name) =>
        Json.toJson(state.newPlayer(name))

      case GetHand(playerSecret) =>
        Json.toJson(state.getHand(playerSecret))

      case GetLobbyAndHand(playerSecret) =>
        Json.toJson(state.lobbyAndHand(playerSecret))

      case Register(secret, socket) =>
        state.register(secret, socket)

      case Unregister(secret, socket) =>
        state.unregister(secret, socket)

      case _ =>
        throw new IllegalArgumentException("Unknown message: " + message)
    })
  }
}
object Game {
  trait Factory {
    def apply(id: String): Actor
  }
}
