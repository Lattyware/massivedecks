package massivedecks.lobby

import massivedecks.models.Game.{Config => ConfigModel}
import massivedecks.models.cardcast.CardcastDeck
import massivedecks.notifications.Notifiers

class Config(notifiers: Notifiers) {

  var decks: List[CardcastDeck] = List()
  var houseRules: Set[String] = Set()
  var password: Option[String] = None

  def config = ConfigModel(decks.map(deck => deck.info), houseRules, password)

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

  def setPassword(newPass: Option[String]) = {
    password = newPass.flatMap(pass => if (pass.isEmpty) None else newPass)
    notifiers.configChange(config)
  }

}
