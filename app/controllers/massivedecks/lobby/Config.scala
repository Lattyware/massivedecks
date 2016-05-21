package controllers.massivedecks.lobby

import models.massivedecks.Game.Config
import controllers.massivedecks.cardcast.CardcastDeck

class Config {

  var decks: List[CardcastDeck] = List()
  var houseRules: Set[String] = Set()

  def config = Config(decks.map(deck => deck.info), houseRules)

  def addDeck(deck: CardcastDeck): Unit = {
    decks = decks :+ deck
  }

  def addHouseRule(rule: String): Unit = {
    houseRules = houseRules + rule
  }

  def removeHouseRule(rule: String): Unit = {
    houseRules = houseRules - rule
  }

}
