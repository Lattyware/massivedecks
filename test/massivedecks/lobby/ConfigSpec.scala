package massivedecks.lobby

import org.specs2._
import org.specs2.mock.Mockito

import massivedecks.notifications.Notifiers
import massivedecks.models.{Game => GameModel}
import massivedecks.models.cardcast.CardcastDeck

/**
  * Specification for the configuration.
  */
class ConfigSpec extends Specification with Mockito { def is = s2"""

    The configuration should
      Return added decks                                    $addedDeck
      Return added house rules                              $addedHouseRule
      Not return removed house rules                        $removedHouseRule
      Ignore removal of house rule that doesn't exist       $nonExistantHouseRule
      The model must accurately reflect the configuration   $modelReflectsConfiguration
  """

  val mockHouseRule = "test"
  val mockNotifiers = mock[Notifiers]
  val mockDeckInfo = mock[GameModel.DeckInfo]
  val mockDeck = mock[CardcastDeck]
  mockDeck.info returns mockDeckInfo

  def mockConfig = new Config(mockNotifiers)

  def addedDeck = {
    val config = mockConfig
    config.addDeck(mockDeck)
    config.decks must contain(exactly(mockDeck))
  }

  def addedHouseRule = {
    val config = mockConfig
    config.addHouseRule(mockHouseRule)
    config.houseRules must contain(exactly(mockHouseRule))
  }

  def removedHouseRule = {
    val config = mockConfig
    config.addHouseRule(mockHouseRule)
    config.removeHouseRule(mockHouseRule)
    config.houseRules must beEmpty
  }

  def nonExistantHouseRule = {
    val config = mockConfig
    config.removeHouseRule(mockHouseRule)
    success
  }

  def modelReflectsConfiguration = {
    val config = mockConfig
    config.addHouseRule(mockHouseRule)
    config.addDeck(mockDeck)
    config.config must_== GameModel.Config(List(mockDeckInfo), Set(mockHouseRule), None)
  }

}
