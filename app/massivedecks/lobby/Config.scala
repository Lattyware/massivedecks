package massivedecks.lobby

import massivedecks.models.Game.{Config => ConfigModel}
import massivedecks.notifications.Notifiers
import massivedecks.models.cardcast.CardcastDeck

class Config(notifiers: Notifiers) {

  var decks: List[CardcastDeck] = List()
  var houseRules: Set[String] = Set()

  def config = ConfigModel(decks.map(deck => deck.info), houseRules)

  def addDeck(deck: CardcastDeck): Unit = {
    decks = decks :+ deck
    notifiers.configChange(config)
  }

  def addHouseRule(rule: String): Unit = {
    houseRules = houseRules + rule
    notifiers.configChange(config)
  }

  def removeHouseRule(rule: String): Unit = {
    houseRules = houseRules - rule
    notifiers.configChange(config)
  }

}
