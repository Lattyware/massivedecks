package controllers.massivedecks.game

import akka.actor.ActorRef
import models.massivedecks.Player
import Player.{Id, Secret}
import play.api.libs.json.{Format, JsObject, JsValue, Json}

import Player.Formatters._
import controllers.massivedecks.game.Actions.Lobby.Formatters._

object Actions {

  object Store {
    sealed trait Action
    case object NewLobby extends Action
    case class LobbyAction(lobbyId: String, action: Lobby.Action) extends Action
    case class PlayerAction(lobbyId: String, action: Player.Action) extends Action
  }

  object Lobby {
    sealed trait Action
    case object GetLobby extends Action
    sealed trait Command extends Action
    case class Register(secret: Secret, socket: ActorRef) extends Action
    case class Unregister(secret: Secret, socket: ActorRef) extends Action
    case class AddDeck(secret: Secret, deckId: String) extends Command
    case class NewGame(secret: Secret) extends Command
    case class Play(secret: Secret, ids: List[Int]) extends Command
    case class Choose(secret: Secret, winner: Int) extends Command
    case class GetLobbyAndHand(secret: Secret) extends Command

    object Action {
      def apply(json: JsValue): Option[Command] =
        (json \ commandFieldName).validate[String].asOpt.flatMap(commandName =>
          json.asOpt[JsObject].flatMap(obj => {
            val command = obj - commandFieldName
            commandName match {
              case "addDeck" => Json.fromJson[AddDeck](command).asOpt
              case "newGame" => Json.fromJson[NewGame](command).asOpt
              case "play" => Json.fromJson[Play](command).asOpt
              case "choose" => Json.fromJson[Choose](command).asOpt
              case "getLobbyAndHand" => Json.fromJson[GetLobbyAndHand](command).asOpt
              case _ => None
            }
          })
        )

      private val commandFieldName = "command"
    }

    object Formatters {
      implicit val addDeckFormat: Format[AddDeck] = Json.format[AddDeck]
      implicit val newGameFormat: Format[NewGame] = Json.format[NewGame]
      implicit val playFormat: Format[Play] = Json.format[Play]
      implicit val chooseFormat: Format[Choose] = Json.format[Choose]
      implicit val getLobbyAndHandFormat: Format[GetLobbyAndHand] = Json.format[GetLobbyAndHand]
    }
  }

  object Player {
    sealed trait Action
    case class NewPlayer(name: String) extends Action
    case class GetHand(secret: Secret) extends Action
    case class Leave(secret: Secret) extends Action
    case object AddAi extends Action

    object Formatters {
      implicit val leaveFormat : Format[Leave] = Json.format[Leave]
      implicit val newPlayerFormat: Format[NewPlayer] = Json.format[NewPlayer]
      implicit val getHandFormat: Format[GetHand] = Json.format[GetHand]
    }
  }

}
