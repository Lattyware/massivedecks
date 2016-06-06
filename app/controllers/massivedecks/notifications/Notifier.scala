package controllers.massivedecks.notifications

import scala.concurrent.ExecutionContext

import models.massivedecks.Player
import models.massivedecks.Player.Formatters._
import play.api.libs.iteratee.Concurrent.Channel
import play.api.libs.iteratee._
import play.api.libs.json.Json

/**
  * Handles websocket notifications.
  */
class Notifier (implicit context: ExecutionContext) {
  var unicastChannel: Option[Channel[String]] = None

  def openedSocket(onConnect: () => Unit, onIdentify: (Player.Secret) => Unit, onClose: () => Unit): (Iteratee[String, Unit], Enumerator[String]) = {
    val iteratee = Notifier.forEachAndOnClose[String](
      message => onIdentify(Json.parse(message).validate[Player.Secret].get),
      onClose
    )
    val enumerator = Concurrent.unicast[String](
      channel => {
        unicastChannel = Some(channel)
        onConnect()
      }
    )
    (iteratee, enumerator)
  }

  def notify(message: String) =
    unicastChannel.foreach { channel =>
      channel.push(message)
    }
}
object Notifier {
  def forEachAndOnClose[E](onMessage: (E) => Unit, onClose: () => Unit): Iteratee[E, Unit] = {
    def cont: Iteratee[E, Unit] = Cont {
      case Input.EOF =>
        onClose()
        Done((), Input.EOF)
      case Input.El(message) =>
        onMessage(message)
        cont
      case Input.Empty =>
        cont
    }
    cont
  }
}
