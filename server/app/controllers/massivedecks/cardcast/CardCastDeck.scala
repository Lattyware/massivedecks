package controllers.massivedecks.cardcast

import models.massivedecks.Game
import Game.{Call, Response}

case class CardCastDeck(id: String, calls: List[Call], responses: List[Response])
