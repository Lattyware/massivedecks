package controllers.massivedecks

import javax.inject.{Inject, Named}

import scala.concurrent.duration._
import scala.concurrent.{ExecutionContext, Future}
import scala.util.{Failure, Success, Try}

import play.api.Play.current
import play.api.libs.json.JsValue
import play.api.mvc._

import akka.actor.ActorRef
import akka.pattern.ask
import akka.util.Timeout

import controllers.massivedecks.game.JsonError
import controllers.massivedecks.game.Actions.Lobby
import controllers.massivedecks.game.Actions.Lobby.GetLobby
import controllers.massivedecks.game.Actions.Player.Formatters._
import controllers.massivedecks.game.Actions.Player.{Leave, AddAi, GetHand, NewPlayer}
import controllers.massivedecks.game.Actions.Store.{LobbyAction, NewLobby, PlayerAction}
import controllers.massivedecks.game.{BadRequestException, RequestFailedException, NotFoundException}
import models.massivedecks.Player.{Id, Secret}

class Application @Inject() (@Named("store") store: ActorRef)(implicit ec: ExecutionContext) extends Controller {
  implicit val timeout: Timeout = 15.seconds // Should be more than the Cardcast API timeout.

  def index() = Action { implicit request =>
    Ok(views.html.massivedecks.index(routes.Application.index().absoluteURL()))
  }

  def createLobby() = Action.async {
    resultOrError(store ? NewLobby)
  }

  def notifications(lobbyId: String) = WebSocket.acceptWithActor[String, String] {
    request => out => NotificationHandler.props(lobbyId, store, out)
  }

  def getLobby(gameCode: String) = Action.async {
    resultOrError(store ? LobbyAction(gameCode, GetLobby))
  }

  def command(gameCode: String) = Action.async(parse.json) { request: Request[JsValue] =>
    Lobby.Action(request.body) match {
      case Some(action) =>
        resultOrError(store ? LobbyAction(gameCode, action))

      case None =>
        Future.successful(BadRequest(JsonError.of("invalid-command")))
    }
  }

  def newPlayer(gameCode: String) = Action.async(parse.json) { request: Request[JsValue] =>
    request.body.validate[NewPlayer].asOpt match {
      case Some(action) =>
        resultOrError(store ? PlayerAction(gameCode, action))

      case None =>
        Future.successful(BadRequest(JsonError.of("badly-formed-name")))
    }
  }

  def getPlayer(gameCode: String, playerId: Int) = Action.async(parse.json) { request: Request[JsValue] =>
    (request.body \ "secret").validate[String].asOpt match {
      case Some(secret) =>
        resultOrError(store ? PlayerAction(gameCode, GetHand(Secret(Id(playerId), secret))))

      case None =>
        Future.successful(BadRequest(JsonError.of("badly-formed-secret")))
    }
  }

  def newAi(gameCode: String) = Action.async {
    resultOrError(store ? PlayerAction(gameCode, AddAi))
  }

  def leave(gameCode: String, playerId: Int) = Action.async(parse.json) { request: Request[JsValue] =>
    (request.body \ "secret").validate[String].asOpt match {
      case Some(secret) =>
        resultOrError(store ? PlayerAction(gameCode, Leave(Secret(Id(playerId), secret))))

      case None =>
        Future.successful(BadRequest(JsonError.of("badly-formed-secret")))
    }
  }

  private def resultOrError(response: Future[Any]): Future[Result] = {
    val result: Future[Try[JsValue]] = response.mapTo[Try[JsValue]]
    result.map({
      case Success(json) =>
        Ok(json).as(JSON)

      case Failure(error) => error match {
          case BadRequestException(msg) =>
            BadRequest(msg)
          case NotFoundException(msg) =>
            NotFound(msg).as(JSON)
          case RequestFailedException(msg) =>
            BadGateway(msg).as(JSON)
          case _ =>
            throw error
        }
    })
  }
}
