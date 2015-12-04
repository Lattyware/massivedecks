package controllers.massivedecks.cardcast

import javax.inject.Inject

import scala.collection.mutable.ListBuffer
import scala.concurrent.Await
import scala.concurrent.duration._

import models.massivedecks.Game
import Game.{Call, Response}
import play.api.libs.json.JsValue
import play.api.libs.ws.WSClient

class CardCastAPI @Inject()(ws: WSClient) {
  private val waitTime: Duration = 5.seconds
  private val apiUrl: String = "https://api.cardcastgame.com/v1"

  private def deckUrl(id: String): String = s"$apiUrl/decks/$id/cards"

  def deck(id: String): CardCastDeck = fromJson(id, getDeck(deckUrl(id)))

  private def getDeck(url: String): JsValue = Await.result(ws.url(url).get(), waitTime).json

  private def fromJson(id: String, deck: JsValue): CardCastDeck = {
    val calls = ListBuffer[Call]()
    val responses = ListBuffer[Response]()
    for (call: JsValue <- (deck \ "calls").validate[List[JsValue]].get) {
      calls += Call((call \ "text").validate[List[String]].get)
    }
    for (response: JsValue <- (deck \ "responses").validate[List[JsValue]].get) {
      responses += Response((response \ "text").validate[List[String]].get.head)
    }
    CardCastDeck(id, calls.toList, responses.toList)
  }
}
