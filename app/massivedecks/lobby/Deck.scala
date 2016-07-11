package massivedecks.lobby

import java.util.UUID

import scala.util.Random

import massivedecks.exceptions.BadRequestException
import massivedecks.models.Errors
import massivedecks.models.Game.{Call, Response}
import massivedecks.models.cardcast.CardcastDeck

/**
  * A live deck of cards in a game, constructed from a collection of cardcast decks.
  *
  * @param decks The cardcast decks.
  * @throws BadRequestException with key "invalid-deck-configuration" if there are no calls or responses. Has value
  *                             "reason" explaining the issue.
  */
case class Deck(decks: List[CardcastDeck]) {
  /**
    * The current calls in the deck.
    */
  var calls: List[Call] = List()

  /**
    * The current responses in the deck.
    */
  var responses: List[Response] = List()

  resetCalls()
  resetResponses()
  BadRequestException.verify(calls.nonEmpty, Errors.InvalidDeckConfiguration("The decks for the game have no calls."))
  BadRequestException.verify(responses.nonEmpty, Errors.InvalidDeckConfiguration("The decks for the game have no responses."))

  /**
    * Draw a call from the deck, reshuffling if the deck runs out.
    *
    * @return The drawn call.
    */
  def drawCall(): Call = {
    if (calls.isEmpty) {
      resetCalls()
    }
    val drawn = calls.head
    calls = calls.tail
    drawn
  }

  /**
    * Draw the given number of responses, reshuffling if the deck runs out.
    *
    * @param count The number of responses to draw.
    * @return The drawn responses.
    */
  def drawResponses(count: Int): List[Response] = {
    if (responses.length < count) {
      val partial = responses.take(count)
      resetResponses()
      partial ++ drawResponses(count - partial.length)
    } else {
      val drawn = responses.take(count)
      responses = responses.drop(count)
      drawn
    }
  }

  /**
    * Populate the active deck with all calls, shuffling them into a random order.
    */
  def resetCalls(): Unit = {
    calls = decks.flatMap(deck => deck.calls).map(call => call.copy(id = UUID.randomUUID().toString))
    shuffleCalls()
  }

  /**
    * Populate the active deck with all responses, shuffling them into a random order.
    */
  def resetResponses(): Unit = {
    responses = decks.flatMap(deck => deck.responses).map(response => response.copy(id = UUID.randomUUID().toString))
    shuffleResponses()
  }

  /**
    * Shuffle the active deck of calls and responses.
    */
  def shuffle(): Unit = {
    shuffleCalls()
    shuffleResponses()
  }

  /**
    * Shuffle the active deck of calls.
    */
  def shuffleCalls(): Unit = calls = Random.shuffle(calls)

  /**
    * Shuffle the active deck of responses.
    */
  def shuffleResponses(): Unit = responses = Random.shuffle(responses)
}
