package massivedecks.notifications

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Promise

import play.api.libs.iteratee.{Enumerator, Iteratee}
import massivedecks.notifications.FakeWebSocketClient.{ReceivedBehaviour, SendingBehaviour}

/**
  * A fake web socket client that sits on the iteratee/enumerator interface and acts like a websocket.
  */
class FakeWebSocketClient(socket: (Iteratee[String, Unit], Enumerator[String]))  {
  private val (iteratee, enumerator) = socket

  /**
    * Connect to the server, following the given behaviours for recieving and sending messages.
 *
    * @param receivedBehaviour The behaviour to follow when recieving messages.
    * @param sendingBehaviour The behaviour to follow when sending messages initially.
    * @param rest Any more behaviours to follow when sending messages after the first finishes.
    */
  def connect(receivedBehaviour: ReceivedBehaviour)(sendingBehaviour: SendingBehaviour, rest: SendingBehaviour*): Unit = {
    val consumer = receivedBehaviour.consumer
    val producer = SendingBehaviour.sequentially(sendingBehaviour :: rest.toList)
    // We bind the consumer first to try to ensure we catch responses to our messages from the producer.
    enumerator(consumer)
    producer(iteratee)
  }

}
object FakeWebSocketClient {

  /**
    * A behaviour to take when receiving messages to the server.
    */
  sealed trait ReceivedBehaviour {
    def consumer: Iteratee[String, Unit]
  }

  /**
    * Ignore all messages from the server.
    */
  case object Ignore extends ReceivedBehaviour {
    val consumer = Iteratee.ignore[String]
  }

  /**
    * Call the given callback with each message as it comes.
 *
    * @param callback The callback.
    */
  case class Callback(callback: (String) => Unit) extends ReceivedBehaviour {
    val consumer = Iteratee.foreach(callback)
  }

  /**
    * A custom consumer from any iteratee, where each chunk is a message, and EOF is the socket closing.
 *
    * @param consumer The iteratee.
    */
  case class Consumer(consumer: Iteratee[String, Unit]) extends ReceivedBehaviour


  /**
    * A behaviour to take when sending messages to the server.
    */
  sealed trait SendingBehaviour {
    def producer: Enumerator[String]
  }
  object SendingBehaviour {
    /**
      * Sequentially merge the given behaviours into a single enumerator. If no behaviours are given, give an eof.
 *
      * @param behaviours The behaviours.
      * @return An enumerator.
      */
    def sequentially(behaviours: List[SendingBehaviour]): Enumerator[String] =
      behaviours match {
        case List() => Enumerator.eof
        case enumerator :: List() => enumerator.producer
        case enumerator :: rest => enumerator.producer andThen sequentially(rest)
      }
  }

  /**
    * Close the socket. Future sends will fail.
    */
  case object Close extends SendingBehaviour {
    val producer = Enumerator.eof[String]
  }

  /**
    * Do nothing, but keep the socket open.
    */
  case object Nothing extends SendingBehaviour {
    val producer = Enumerator.empty[String]
  }

  /**
    * Send the exact values, keeping the socket open when done.
 *
    * @param values The values to send.
    */
  case class Values(values: String*) extends SendingBehaviour {
    val producer = Enumerator.enumerate(values)
  }

  /**
    * Send the value of the promise when it succeeds.
 *
    * @param promise The promise.
    */
  case class PromisedValue(promise: Promise[String]) extends SendingBehaviour {
    val producer = Enumerator.flatten(promise.future.map(value => Enumerator(value)))
  }

  /**
    * A custom producer from any enumerator, where each chunk is a message, and EOF is the socket closing.
 *
    * @param producer Thr enumerator.
    */
  case class Producer(producer: Enumerator[String]) extends SendingBehaviour

}
