package controllers.massivedecks.lobby

import models.massivedecks.Game.{Config => ConfigModel}
import controllers.massivedecks.cardcast.CardcastDeck
import controllers.massivedecks.notifications.Notifiers

class Config(notifiers: Notifiers) {

  var decks: List[CardcastDeck] = List()
  var houseRules: Set[String] = Set()

  def config = ConfigModel(decks.map(deck => deck.info), houseRules)

  def addDeck(deck: CardcastDeck): Unit = {
    decks = decks :+ deck
    notifiers.configChanged(config)
  }

  def addHouseRule(rule: String): Unit = {
    houseRules = houseRules + rule
    notifiers.configChanged(config)
  }

  def removeHouseRule(rule: String): Unit = {
    houseRules = houseRules - rule
    notifiers.configChanged(config)
  }

}
