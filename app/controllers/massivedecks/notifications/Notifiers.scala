package controllers.massivedecks.notifications

import scala.concurrent.ExecutionContext
import scala.reflect.ClassTag

import models.massivedecks.Event
import models.massivedecks.Event.Formatters._
import models.massivedecks.Game
import models.massivedecks.Player
import models.massivedecks.Lobby
import play.api.libs.iteratee.{Concurrent, Enumerator, Iteratee}
import play.api.libs.json.{JsObject, JsValue, Json}

/**
  * Manages open sockets.
  */
class Notifiers (implicit context: ExecutionContext) {

  val (broadcastEnumerator, broadcastChannel) = Concurrent.broadcast[String]
  var identified: Map[Player.Id, Notifier] = Map()

  /**
    * Sets up notifications for a new websocket.
    *
    * @param onIdentify When we get an identification message from the client, this will be run. This should validate
    *                   the secret and throw if it isn't correct.
    * @param onClose When a client that has previously identified disconnects, this will be run.
    * @return The websocket iteratee and enumerator.
    */
  def openedSocket(onIdentify: Player.Secret => Lobby.LobbyAndHand, onClose: (Player.Id => Unit)): (Iteratee[String, Unit], Enumerator[String]) = {
    val notifier = new Notifier()
    val (unicastIteratee, unicastEnumerator) = notifier.openedSocket(
      () => notifier.notify("identify"),
      (secret) => {
        val lobbyAndHand = onIdentify(secret)
        identified += (secret.id -> notifier)
        notifier.notify(eventToString[Event.Sync](Json.toJson(Event.Sync(lobbyAndHand))))
      },
      () => {
        identified.find(item => notifier == item._2).foreach { item =>
          val (id, _) = item
          identified -= id
          onClose(id)
        }
      }
    )
    (unicastIteratee, unicastEnumerator.interleave(broadcastEnumerator))
  }

  def playerJoined(player: Player): Unit =
    notifyAll[Event.PlayerJoin](Json.toJson(Event.PlayerJoin(player)))

  def configChanged(config: Game.Config): Unit =
    notifyAll[Event.ConfigChange](Json.toJson(Event.ConfigChange(config)))

  def gameStart(): Unit =
    notifyAll[Event.GameStart](Json.toJson(Event.GameStart()))

  def roundPlayed(playedCards: Int): Unit =
    notifyAll[Event.RoundPlayed](Json.toJson(Event.RoundPlayed(playedCards)))

  def playerStatus(playerId: Player.Id, status: Player.Status): Unit =
    notifyAll[Event.PlayerStatus](Json.toJson(Event.PlayerStatus(playerId, status)))

  def roundEnd(finishedRound: Game.FinishedRound): Unit =
    notifyAll[Event.RoundEnd](Json.toJson(Event.RoundEnd(finishedRound)))

  def playerScoreChange(playerId: Player.Id, score: Int): Unit =
    notifyAll[Event.PlayerScoreChange](Json.toJson(Event.PlayerScoreChange(playerId, score)))

  def playerLeft(playerId: Player.Id): Unit =
    notifyAll[Event.PlayerLeft](Json.toJson(Event.PlayerLeft(playerId)))

  def gameEnd(): Unit =
    notifyAll[Event.GameEnd](Json.toJson(Event.GameEnd()))

  def playerReconnect(playerId: Player.Id): Unit =
    notifyAll[Event.PlayerReconnect](Json.toJson(Event.PlayerReconnect(playerId)))

  def playerDisconnect(playerId: Player.Id): Unit =
    notifyAll[Event.PlayerDisconnect](Json.toJson(Event.PlayerDisconnect(playerId)))

  def roundJudging(playedCards: List[List[Game.Response]]): Unit =
    notifyAll[Event.RoundJudging](Json.toJson(Event.RoundJudging(playedCards)))

  def roundStart(czar: Player.Id, call: Game.Call): Unit =
    notifyAll[Event.RoundStart](Json.toJson(Event.RoundStart(czar, call)))

  def handChange(playerId: Player.Id, hand: Game.Hand): Unit =
    notify[Event.HandChange](playerId, Json.toJson(Event.HandChange(hand)))

  private def notify[E: ClassTag](player: Player.Id, event: JsValue) =
    identified.get(player).foreach { notifier => notifier.notify(eventToString[E](event)) }

  private def notifyAll[E: ClassTag](event: JsValue) =
    broadcastChannel.push(eventToString(event))

  def eventToString[E: ClassTag](event: JsValue): String = {
    val name = Json.toJson(implicitly[ClassTag[E]].runtimeClass.getSimpleName)
    val eventObject = event.as[JsObject]
    val namedEvent = eventObject + ("event", name)
    namedEvent.toString()
  }

}
