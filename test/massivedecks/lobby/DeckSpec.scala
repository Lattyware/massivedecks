package massivedecks.lobby

import massivedecks.exceptions.BadRequestException
import massivedecks.models.Game.{Call, Response}
import massivedecks.models.cardcast.CardcastDeck
import massivedecks.matchers.Matchers._
import org.specs2._
import org.specs2.mock.Mockito

/**
  * Specification for the deck.
  */
class DeckSpec extends Specification with Mockito { def is = s2"""

    The deck should
      Throw if there are not any responses.     $noResponses
      Throw if there are not any calls.         $noCalls
      Reused responses should get unique ids.   $uniqueIdsOnReusedResponses
      Reused calls should get unique ids.       $uniqueIdsOnReusedCalls

  """

  def call = Call("call", List("callContent", "callContent"))
  def response = Response("response", "responseContent")

  def deckNoResponses = CardcastDeck("noResponses", "", List(call), List())
  def deckNoCalls = CardcastDeck("noCalls", "", List(), List(response))

  def decksOneOfEach = List(deckNoResponses, deckNoCalls)

  def noResponses =
    new Deck(List(deckNoResponses)) must throwA[BadRequestException]

  def noCalls =
    new Deck(List(deckNoCalls)) must throwA[BadRequestException]

  def uniqueIdsOnReusedResponses = {
    val deck = new Deck(decksOneOfEach)
    deck.drawResponses(2) must haveNoDuplicateValues
  }

  def uniqueIdsOnReusedCalls = {
    val deck = new Deck(decksOneOfEach)
    deck.drawCall() must_!= deck.drawCall()
  }

}
