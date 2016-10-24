package massivedecks.notifications

import scala.concurrent.Promise

import org.specs2._
import org.specs2.concurrent.ExecutionEnv
import org.specs2.mock.Mockito

import play.api.libs.iteratee.{Enumerator, Iteratee}
import play.api.libs.json.Json

import massivedecks.exceptions.ForbiddenException
import massivedecks.notifications.FakeWebSocketClient._
import massivedecks.models.{Errors, Game, Lobby, Player}
import massivedecks.models.Game.Formatters._
import massivedecks.models.Lobby.Formatters._
import massivedecks.models.Player.Formatters._

/**
  * Specification for the notifier manager.
  */
class NotifiersSpec(implicit ee: ExecutionEnv) extends Specification with Mockito { def is = s2"""

    The notifier manager should
      Ask a new client to identify                                                      $askNewClientToIdentify
      Call the identification callback when a client tries to identify                  $identificationCallback
      Sync after identifying                                                            $syncAfterIdentifying
      Call the close callback when a socket is closed                                   $closeCallback
      Send broadcast messages to all clients                                            $broadcast
      Send directed messages to the right client                                        $unicast
      Don't send directed messages to other clients                                     $unicastWrongClient
      If identification fails, don't send directed messages to the client               $unicastFailedIdentification
  """

  val identifyRequest = "identify"
  val lobbyAndHand = Lobby.LobbyAndHand(Lobby.Lobby("", Player.Id(0), Game.Config(List(), Set(), None), List(), Game.State.Configuring()), Game.Hand(List()))
  val testSecret = Player.Secret(Player.Id(0), "secret")

  def askNewClientToIdentify = {
    val notifiers = new Notifiers()
    val promise = Promise[String]()
    new FakeWebSocketClient(simpleOpenedSocket(notifiers)).connect(Callback(message => promise.success(message)))(Nothing)
    promise.future must be_==(identifyRequest).await
  }

  def identificationCallback = {
    val notifiers = new Notifiers()
    val promisedSecret = Promise[Player.Secret]()
    identifiedClient(notifiers, testSecret, message => {}, notifiers.openedSocket(
      (secret) => {
        promisedSecret.success(secret)
        lobbyAndHand
      },
      (id) => {}
    ))()
    promisedSecret.future must be_==(testSecret).await
  }

  def syncAfterIdentifying = {
    val notifiers = new Notifiers()

    val promisedSync = Promise[String]()
    identifiedClient(notifiers, testSecret, message => promisedSync.success(message), ignoreFirstSync = false)()

    val expectedMessage = Json.obj(
      "event" -> "Sync",
      "lobbyAndHand" -> Json.toJson(lobbyAndHand)
    ).toString

    promisedSync.future must be_==(expectedMessage).await
  }

  def closeCallback = {
    val notifiers = new Notifiers()
    val promisedId = Promise[Player.Id]()
    identifiedClient(notifiers, testSecret, message => {}, notifiers.openedSocket(
      (secret) => lobbyAndHand,
      (id) => { promisedId.success(id) }
    ))(Close)
    promisedId.future must be_==(testSecret.id).await
  }

  def broadcast = {
    val notifiers = new Notifiers()

    val promisedIdentifiedMessage = Promise[String]()
    identifiedClient(notifiers, testSecret, message => promisedIdentifiedMessage.success(message))()

    val promisedUnidentifiedMessage = Promise[String]()
    new FakeWebSocketClient(simpleOpenedSocket(notifiers)).connect(
      Callback(message =>
        if (message != identifyRequest) {
          promisedUnidentifiedMessage.success(message)
        })
    )(
      Nothing
    )

    val call = Game.Call("call-id", List("call", "call"))
    val czar = Player.Id(0)

    // We need to wait for the notifier to connect to the socket before sending.
    // In the real world we know first messages are lossy and sync deals with anything missed.
    Thread.sleep(100)
    val expectedMessage = Json.obj(
      "event" -> "GameStart",
      "czar" -> Json.toJson(czar),
      "call" -> Json.toJson(call)
    ).toString
    notifiers.gameStart(czar, call)

    promisedIdentifiedMessage.future.zip(promisedUnidentifiedMessage.future) must be_==((expectedMessage, expectedMessage)).await
  }

  def unicast = {
    val notifiers = new Notifiers()

    val promisedMessage = Promise[String]()
    identifiedClient(notifiers, testSecret, message => promisedMessage.success(message))()

    val hand = Game.Hand(List())
    val expectedMessage = Json.obj(
      "event" -> "HandChange",
      "hand" -> Json.toJson(hand)
    ).toString

    // We need to wait for the notifier to connect to the socket before sending.
    // In the real world we know first messages are lossy and sync deals with anything missed.
    Thread.sleep(100)
    notifiers.handChange(testSecret.id, hand)

    promisedMessage.future must be_==(expectedMessage).await
  }

  def unicastWrongClient = {
    val notifiers = new Notifiers()

    val promisedMessageWrong = Promise[Nothing]()
    identifiedClient(notifiers, testSecret, message => promisedMessageWrong.failure(throw new IllegalStateException()))()

    val secret = Player.Secret(Player.Id(99), "secret")
    identifiedClient(notifiers, secret, message => {})()

    // We need to wait for the notifier to connect to the socket before sending.
    // In the real world we know first messages are lossy and sync deals with anything missed.
    Thread.sleep(100)
    notifiers.handChange(testSecret.id, Game.Hand(List()))

    // Wait for us to get the message on the wrong client.
    Thread.sleep(1000)
    promisedMessageWrong.future.value match {
      case None => success
      case Some(_) => failure
    }
  }

  def unicastFailedIdentification = {
    val notifiers = new Notifiers()

    val promisedMessageWrong = Promise[Nothing]()
    identifiedClient(notifiers, testSecret, message => promisedMessageWrong.failure(throw new IllegalStateException()),
      notifiers.openedSocket(
        (secret) => throw ForbiddenException(Errors.SecretWrongOrNotAPlayer()),
        (id) => {}
      ))()

    // We need to wait for the notifier to connect to the socket before sending.
    // In the real world we know first messages are lossy and sync deals with anything missed.
    Thread.sleep(100)
    notifiers.handChange(testSecret.id, Game.Hand(List()))

    // Wait for us to get the message despite the auth failure.
    Thread.sleep(1000)
    promisedMessageWrong.future.value match {
      case None => success
      case Some(_) => failure
    }
  }

  private def simpleOpenedSocket(notifiers: Notifiers) = notifiers.openedSocket(
      (secret) => lobbyAndHand,
      (id) => {}
    )

  private def identifiedClient(notifiers: Notifiers, secret: Player.Secret, callback: String => Unit,
                               socketOrNulls: (Iteratee[String, Unit], Enumerator[String]) = (null, null),
                               ignoreFirstSync: Boolean = true)
                              (sendingBehaviours: SendingBehaviour*) = {
    val socket = if (socketOrNulls == (null, null)) {
      simpleOpenedSocket(notifiers)
    } else {
      socketOrNulls
    }
    val promisedIdentification = Promise[String]()
    var ignoredFirstSync = !ignoreFirstSync
    new FakeWebSocketClient(socket).connect(
      Callback(message => if (message == identifyRequest) {
        promisedIdentification.success(Json.toJson(secret).toString)
      } else {
        if (!ignoredFirstSync && message.startsWith("{\"event\":\"Sync\"")) {
          ignoredFirstSync = true
        } else {
          callback(message)
        }
      })
    )(
      PromisedValue(promisedIdentification),
      sendingBehaviours: _*
    )
  }

}
