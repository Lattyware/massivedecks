package controllers.massivedecks.game

import scala.util.Random

import controllers.massivedecks.cardcast.CardCastDeck
import models.massivedecks.Game.{Response, Call}

/**
  * A live deck of cards in a game, constructed from a collection of decks.
  * @param decks The decks.
  */
case class Deck(decks: Set[CardCastDeck]) {
  var calls: List[Call] = List()
  var responses: List[Response] = List()
  resetCalls()
  resetResponses()

  if (calls.length < 1) {
    throw new IllegalStateException("The deck must have at least one call in it.")
  }

  def drawCall(): Call = {
    if (calls.isEmpty) {
      resetCalls()
    }
    val drawn = calls.head
    calls = calls.tail
    drawn
  }

  def drawResponses(count: Int): List[Response] = {
    if (responses.length < count) {
      val partial = responses.take(count)
      shuffleResponses()
      partial ++ drawResponses(count - partial.length)
    } else {
      val drawn = responses.take(count)
      responses = responses.drop(count)
      drawn
    }
  }

  def resetCalls(): Unit = {
    calls = (for (deck <- decks) yield deck.calls).flatten.toList
    shuffleCalls()
  }
  def resetResponses(): Unit = {
    responses = (for (deck <- decks) yield deck.responses).flatten.toList
    shuffleResponses()
  }

  def shuffle(): Unit = {
    shuffleCalls()
    shuffleResponses()
  }
  def shuffleCalls(): Unit = calls = Random.shuffle(calls)
  def shuffleResponses(): Unit = responses = Random.shuffle(responses)
}
