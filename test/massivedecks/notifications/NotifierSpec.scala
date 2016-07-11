package massivedecks.notifications

import scala.concurrent.Promise

import massivedecks.models.Player
import massivedecks.notifications.FakeWebSocketClient._
import Player.Formatters._
import org.specs2._
import org.specs2.concurrent.ExecutionEnv
import org.specs2.mock.Mockito
import play.api.libs.json.Json

/**
  * Specification for the notifier.
  */
class NotifierSpec(implicit ee: ExecutionEnv) extends Specification with Mockito { def is = s2"""

    The notifier should
      Run the connection callback when the websocket is connected                 $connectionCallback
      Run the identification callback when recieving a secret on the websocket    $identificationCallback
      Run the closure callback when the websocket is closed                       $closureCallback
      Notifications are sent to the websocket as expected                         $sendMessage

  """

  val testSecret = Player.Secret(Player.Id(0), "secret")
  val testMessage = "Test Message"

  def connectionCallback = {
    val notifier = new Notifier()
    val promise = Promise[Boolean]()
    new FakeWebSocketClient(notifier.openedSocket(
      () => { promise.success(true) },
      (secret) => {},
      () => {}
    )).connect(Ignore)(Nothing)
    promise.future must be_==(true).await
  }

  def identificationCallback = {
    val notifier = new Notifier()
    val promise = Promise[Player.Secret]()
    new FakeWebSocketClient(notifier.openedSocket(
      () => {},
      (secret) => { promise.success(secret) },
      () => {}
    )).connect(Ignore)(Values(Json.toJson(testSecret).toString()))
    promise.future must be_==(testSecret).await
  }

  def closureCallback = {
    val notifier = new Notifier()
    val promise = Promise[Boolean]()
    new FakeWebSocketClient(notifier.openedSocket(
      () => {},
      (secret) => {},
      () => { promise.success(true) }
    )).connect(Ignore)(Close)
    promise.future must be_==(true).await
  }

  def sendMessage = {
    val notifier = new Notifier()
    val promise = Promise[String]()
    new FakeWebSocketClient(notifier.openedSocket(
      () => {},
      (secret) => {},
      () => {}
    )).connect(Callback(message => promise.success(message)))(Nothing)
    // We need to wait for the notifier to connect to the socket before sending.
    // In the real world we know first messages are lossy and sync deals with anything missed.
    Thread.sleep(100)
    notifier.notify(testMessage)
    promise.future must be_==(testMessage).await
  }

}
