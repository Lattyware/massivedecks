package controllers.massivedecks.cardcast

import java.time.Instant
import javax.inject.Inject

import scala.collection.mutable.ListBuffer
import scala.concurrent.duration._
import scala.concurrent.{Await, ExecutionContext, Future, Promise}
import scala.util.Try

import play.api.libs.json.JsValue
import play.api.libs.ws.WSClient
import models.massivedecks.Game.{Call, Response}
import controllers.massivedecks.exceptions.BadRequestException

class CardcastAPI @Inject() (ws: WSClient) (implicit ec: ExecutionContext)  {
  private val apiUrl: String = "https://api.cardcastgame.com/v1"

  private def deckUrl(id: String): String = {
    BadRequestException.verify(id.length > 0, "deck-not-found")
    s"$apiUrl/decks/$id"
  }
  private def cardsUrl(id: String): String = s"${deckUrl(id)}/cards"

  private val cacheFor = java.time.Duration.ofMinutes(15)
  private var cache = Map[String, (CardcastDeck, Instant)]()

  /**
    * Get a future that either returns the deck or blows up after 10 seconds of waiting on Cardcast.
    *
    * @param id The id of the deck to get.
    * @return See above.
    */
  def deck(id: String): Future[CardcastDeck] = {
    cache.get(id) match {
      case Some((deck, expiresAt)) =>
        if (Instant.now.isBefore(expiresAt)) {
          Future.successful(deck)
        } else {
          requestDeck(id)
        }
      case None =>
        requestDeck(id)
    }
  }

  private def requestDeck(id: String): Future[CardcastDeck] = {
    val deckInfo = requestJson(deckUrl(id)).map(parseInfo)
    val cards = requestJson(cardsUrl(id)).map(parseCards)

    val futureDeck = for {
      name <- deckInfo
      (calls, responses) <- cards
    } yield CardcastDeck(id, name, calls, responses)

    futureDeck.onSuccess { case deck =>
      cache += id -> (deck, Instant.now.plus(cacheFor))
    }

    futureDeck
  }

  private def requestJson(url: String): Future[JsValue] =
    ws.url(url).get().map(response => response.json)

  private def parseInfo(deckInfo: JsValue): String = {
    Try(
      (deckInfo \ "name").validate[String].get
    ).getOrElse {
      parseError(deckInfo)
    }
  }

  private def parseCards(cards: JsValue): (List[Call], List[Response]) = {
    Try({
      val calls = ListBuffer[Call]()
      val responses = ListBuffer[Response]()
      for (call: JsValue <- (cards \ "calls").validate[List[JsValue]].get) {
        calls += Call((call \ "id").validate[String].get, (call \ "text").validate[List[String]].get)
      }
      for (response: JsValue <- (cards \ "responses").validate[List[JsValue]].get) {
        responses += Response((response \ "id").validate[String].get, (response \ "text").validate[List[String]].get.head)
      }
      (calls.toList, responses.toList)
    }).getOrElse {
      parseError(cards)
    }
  }

  private def parseError[T](error: JsValue): T = {
    (error \ "id").validate[String].asOpt match {
      case Some("not_found") => throw BadRequestException.json("deck-not-found")
      case Some(errorName) => throw new Exception(s"Cardcast gave an unknown error ('$errorName') when trying to retrieve the deck.")
      case None => throw new Exception(s"Cardcast gave an error that couldn't be parsed when trying to retrieve the deck.")
    }
  }
}
object CardCastAPI {
  def wait(duration: FiniteDuration): Try[Future[Nothing]] = Try(Await.ready(Promise().future, duration))
}
