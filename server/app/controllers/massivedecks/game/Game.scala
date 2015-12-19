package controllers.massivedecks.game

import javax.inject.Inject

import scala.concurrent.ExecutionContext
import scala.util.{Success, Failure, Try}

import akka.actor.Actor
import com.google.inject.assistedinject.Assisted
import play.api.libs.json.Json

import models.massivedecks.Lobby.Formatters._
import models.massivedecks.Player.Formatters._
import models.massivedecks.Game.Formatters._
import models.massivedecks.Player.Secret
import controllers.massivedecks.cardcast.CardCastDeck
import controllers.massivedecks.game.Game.AddRetrievedDeck
import controllers.massivedecks.game.Actions.Player.{Leave, AddAi, GetHand, NewPlayer}
import controllers.massivedecks.game.Actions.Lobby._

class Game @Inject()(private val state: State, @Assisted private val id: String)(implicit ec: ExecutionContext) extends Actor {
  def receive = {
    case message @ _ => doReceive(message)
  }

  def doReceive(message: Any) = {
    message match {
      case GetLobby =>
        sender() ! Try {
          Json.toJson(state.lobby)
        }

      case AddDeck(secret, deckId) =>
        val originalSender = sender()
        val attempt = Try {
          state.retrieveDeck(secret, deckId)
            .map(deck => AddRetrievedDeck(secret, deck))
            .onComplete({
              case Success(result) => self.tell(result, originalSender)
              case Failure(failure) => originalSender ! Failure(failure)
            })
        }
        if (attempt.isFailure) {
          sender() ! attempt
        }

      case AddRetrievedDeck(secret, deck) =>
        println(sender())
        sender() ! Try {
          state.addDeck(secret, deck)
          Json.toJson(state.lobbyAndHand(secret))
        }

      case NewGame(secret) =>
        sender() ! Try {
          state.newGame(secret)
          Json.toJson(state.lobbyAndHand(secret))
        }

      case Play(secret, ids) =>
        sender() ! Try {
          state.play(secret, ids)
          Json.toJson(state.lobbyAndHand(secret))
        }

      case Choose(secret, winner) =>
        sender() ! Try {
          state.choose(secret, winner)
          Json.toJson(state.lobbyAndHand(secret))
        }

      case NewPlayer(name) =>
        sender() ! Try {
          Json.toJson(state.newPlayer(name))
        }

      case GetHand(playerSecret) =>
        sender() ! Try {
          Json.toJson(state.getHand(playerSecret))
        }

      case GetLobbyAndHand(playerSecret) =>
        sender() ! Try {
          Json.toJson(state.lobbyAndHand(playerSecret))
        }

      case Register(secret, socket) =>
        sender() ! Try {
          state.register(secret, socket)
        }

      case Unregister(secret, socket) =>
        sender() ! Try {
          state.unregister(secret, socket)
        }

      case AddAi =>
        sender() ! Try {
          state.newAi()
          Json.toJson("")
        }

      case Leave(secret) =>
        sender() ! Try {
          state.leave(secret)
          Json.toJson(state.lobbyAndHand(secret))
        }

      case Skip(secret, players) =>
        sender() ! Try {
          state.skip(secret, players)
          Json.toJson(state.lobbyAndHand(secret))
        }

      case Back(secret) =>
        sender() ! Try {
          state.back(secret)
          Json.toJson(state.lobbyAndHand(secret))
        }

      case _ =>
        sender() ! Try {
          throw new Exception("Unknown message: " + message)
        }
    }
  }
}
object Game {
  case class AddRetrievedDeck(secret: Secret, deck: CardCastDeck)

  trait Factory {
    def apply(id: String): Actor
  }
}
