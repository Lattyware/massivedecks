package massivedecks.controllers

import javax.inject.Inject

import scala.concurrent.{ExecutionContext, Future}
import scala.util.{Failure, Success, Try}

import akka.stream.scaladsl.{Flow, Sink, Source}
import play.api.libs.json.{JsResult, JsValue, Json}
import play.api.mvc._
import massivedecks.exceptions._
import massivedecks.models.Errors
import massivedecks.models.Game.Formatters._
import massivedecks.models.Lobby.Formatters._
import massivedecks.models.Lobby.GameCodeAndSecret
import massivedecks.models.Player
import massivedecks.models.Player.Formatters._
import massivedecks.stores.LobbyStore
import play.api.libs.streams.Streams

class API @Inject()(store: LobbyStore) (implicit context: ExecutionContext) extends Controller {

  def createLobby() = Action(parse.json) { request: Request[JsValue] =>
    wrap {
      val name = (request.body \ "name").validate[String].getOrElse(throw BadRequestException(Errors.InvalidName()))
      val gameCode = store.newLobby(name)
      store.performInLobby(gameCode) { lobby =>
        Json.toJson(GameCodeAndSecret(lobby.gameCode, lobby.owner))
      }
    }
  }

  def notifications(gameCode: String) = WebSocket.acceptOrResult[String, String] { requestHeader => Future {
    Try {
      store.performInLobby(gameCode) { lobby =>
        lobby.register()
      }
    } match {
      case Success((iteratee, enumerator)) =>
        val (sub, _) = Streams.iterateeToSubscriber(iteratee)
        val pub = Streams.enumeratorToPublisher(enumerator)
        Right(Flow.fromSinkAndSource(Sink.fromSubscriber(sub), Source.fromPublisher(pub)))

      case Failure(error) =>
        error match {
          case exception: RequestException =>
            Left(Status(exception.statusCode)(exception.details.toJson()))
          case _ =>
            throw error
        }
    }
  } }

  def getLobby(gameCode: String) = Action {
    wrap(store.readFromLobby(gameCode) { lobby =>
      Json.toJson(lobby.lobby)
    })
  }

  def command(gameCode: String) = Action(parse.json) { request: Request[JsValue] =>
    wrap {
      store.performInLobby(gameCode) { lobby =>
        val secret = (request.body \ "secret").validate[Player.Secret].getOrElse(throw ForbiddenException(Errors.BadlyFormedSecret()))
        extractCommandArgument((request.body \ "command").validate[String]) match {
          case "addDeck" => lobby.addDeck(secret, extractCommandArgument((request.body \ "playCode").validate[String]))
          case "newGame" => lobby.newGame(secret)
          case "play" => lobby.play(secret, extractCommandArgument((request.body \ "ids").validate[List[String]]))
          case "choose" => lobby.choose(secret, extractCommandArgument((request.body \ "winner").validate[Int]))
          case "getLobbyAndHand" => lobby.getLobbyAndHand(secret)
          case "skip" => lobby.skip(secret, extractCommandArgument((request.body \ "players").validate[Set[Player.Id]]))
          case "back" => lobby.back(secret)
          case "enableRule" => lobby.enableRule(secret, extractCommandArgument((request.body \ "rule").validate[String]))
          case "disableRule" => lobby.disableRule(secret, extractCommandArgument((request.body \ "rule").validate[String]))
          case "redraw" => lobby.redraw(secret)
          case "setPassword" => lobby.setPassword(secret, (request.body \ "password").asOpt[String])
          case unknown => throw BadRequestException(Errors.InvalidCommand(unknown))
        }
      }
    }
  }

  def newPlayer(gameCode: String) = Action(parse.json) { request: Request[JsValue] =>
    wrap {
      val name = (request.body \ "name").validate[String].getOrElse(throw BadRequestException(Errors.InvalidName()))
      store.performInLobby(gameCode) { lobby =>
        Json.toJson(lobby.newPlayer(name, (request.body \ "password").asOpt[String]))
      }
    }
  }

  def getPlayer(gameCode: String, playerId: Int) = Action(parse.json) { request: Request[JsValue] =>
    wrap(store.readFromLobby(gameCode) { lobby =>
      val secret = extractSecret(request)
      Json.toJson(lobby.getHand(secret))
    })
  }

  def getHistory(gameCode: String) = Action { request =>
    wrap(store.readFromLobby(gameCode) { lobby =>
      Json.toJson(lobby.gameHistory())
    })
  }

  def newAi(gameCode: String) = Action(parse.json) { request: Request[JsValue] =>
    wrap(store.performInLobby(gameCode) { lobby =>
      val secret = extractSecret(request)
      lobby.newAi(secret)
      Json.toJson("")
    })
  }

  def leave(gameCode: String, playerId: Int) = Action(parse.json) { request: Request[JsValue] =>
    wrap(store.performInLobby(gameCode) { lobby =>
      val secret = extractSecret(request)
      lobby.leave(secret)
      Json.toJson("")
    })
  }

  private def extractSecret(request: Request[JsValue]) =
    request.body.validate[Player.Secret].getOrElse(throw ForbiddenException(Errors.BadlyFormedSecret()))

  private def extractCommandArgument[T](value: JsResult[T]) =
    value.getOrElse(throw BadRequestException(Errors.InvalidCommand("")))

  private def wrap(attempt: => JsValue) = {
    (Try(attempt) match {
      case Success(result) =>
        Ok(result)

      case Failure(error) =>
        error match {
          case exception: RequestException =>
            Status(exception.statusCode)(exception.details.toJson())
          case _ =>
            throw error
        }
    }).as(JSON)
  }

}
