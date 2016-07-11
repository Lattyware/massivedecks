package massivedecks.notifications

import scala.concurrent.ExecutionContext

import massivedecks.models.Player
import Player.Formatters._
import play.api.libs.iteratee.Concurrent.Channel
import play.api.libs.iteratee._
import play.api.libs.json.Json

/**
  * Handles websocket notifications.
  */
class Notifier (implicit context: ExecutionContext) {
  private var unicastChannel: Option[Channel[String]] = None

  /**
    * Call when a socket has been opened for the notifier.
    * @param onConnect The callback when the socket connects.
    * @param onIdentify The callback when the client identifies down the socket.
    * @param onClose The callback when the socket closes.
    * @return The iteratee and enumerator for the socket.
    */
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

  /**
    * Notify the client down the socket.
    * @param message The message to send.
    */
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
