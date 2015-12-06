package controllers.massivedecks.cardcast

import models.massivedecks.Game.{Call, DeckInfo, Response}

case class CardCastDeck(id: String, name: String, calls: List[Call], responses: List[Response]) {
  def info: DeckInfo = DeckInfo(id, name, calls.length, responses.length)
}
