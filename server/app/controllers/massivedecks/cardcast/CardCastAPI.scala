package controllers.massivedecks.cardcast

import javax.inject.Inject

import scala.collection.mutable.ListBuffer
import scala.concurrent.duration._
import scala.concurrent.{ExecutionContext, Future}

import akka.pattern.after
import play.api.libs.concurrent.Akka
import play.api.Play.current
import play.api.libs.json.JsValue
import play.api.libs.ws.WSClient

import models.massivedecks.Game.{Call, Response}

class CardCastAPI @Inject()(ws: WSClient)(implicit ec: ExecutionContext)  {
  private val apiUrl: String = "https://api.cardcastgame.com/v1"

  private def deckUrl(id: String): String = s"$apiUrl/decks/$id"
  private def cardsUrl(id: String): String = s"${deckUrl(id)}/cards"

  /**
    * Get a future that either returns the deck or blows up after 10 seconds of waiting on CardCast.
    * @param id The id of the deck to get.
    * @param timeout How long to wait on CardCast.
    * @return See above.
    */
  def deck(id: String, timeout: FiniteDuration = 10.seconds): Future[CardCastDeck] = {
    val deckInfo = requestJson(deckUrl(id)).map(parseInfo)
    val cards = requestJson(cardsUrl(id)).map(parseCards)

    val deck = for {
      name <- deckInfo
      (calls, responses) <- cards
    } yield CardCastDeck(id, name, calls, responses)

    val timeoutError = after(timeout, using=Akka.system.scheduler)(
      Future.failed(new IllegalStateException("Timed out waiting for a response from CardCast.")))

    Future firstCompletedOf Seq(deck, timeoutError)
  }

  private def requestJson(url: String): Future[JsValue] =
    ws.url(url).get().map(response => response.json)

  private def parseInfo(deckInfo: JsValue): String = {
    (deckInfo \ "name").validate[String].get
  }

  private def parseCards(cards: JsValue): (List[Call], List[Response]) = {
    val calls = ListBuffer[Call]()
    val responses = ListBuffer[Response]()
    for (call: JsValue <- (cards \ "calls").validate[List[JsValue]].get) {
      calls += Call((call \ "text").validate[List[String]].get)
    }
    for (response: JsValue <- (cards \ "responses").validate[List[JsValue]].get) {
      responses += Response((response \ "text").validate[List[String]].get.head)
    }
    (calls.toList, responses.toList)
  }
}
