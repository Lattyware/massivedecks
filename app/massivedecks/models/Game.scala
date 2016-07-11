package massivedecks.models

import play.api.libs.json.{Format, Json}

import massivedecks.models.Player.Formatters._

/**
  * Created by gareth on 30/06/16.
  */
object Game {

  sealed trait Card

  case class Call(id: String, parts: List[String]) extends Card {
    require(parts.length > 1, "A call must have at least one slot.")

    def slots: Int = parts.length - 1

    def withResponses(responses: List[Response]): String =
      intersperse(parts, responses.map(response => response.text)).mkString("")
  }

  case class Response(id: String, text: String) extends Card

  case class DeckInfo(id: String, name: String, calls: Int, responses: Int)

  case class Config(decks: List[DeckInfo], houseRules: Set[String])

  case class Round(czar: Player.Id, call: Call, responses: Responses, afterTimeLimit: Boolean) {
    require(responses.revealed.isEmpty ||
      responses.revealed.get.cards.forall(playerResponses => playerResponses.length == call.slots),
        "Plays for a call must have a number of responses equal to the number of spots in the call.")

    def inPickingState = responses.revealed.isEmpty
    def inJudgingState = responses.revealed.isDefined && responses.revealed.get.playedByAndWinner.isEmpty
    def inFinishedState = responses.revealed.isDefined && responses.revealed.get.playedByAndWinner.isDefined

    def byState[T](picking: (Player.Id, Call, Int) => T,
                   judging: (Player.Id, Call, List[List[Response]]) => T,
                   finished: (Player.Id, Call, List[List[Response]], PlayedByAndWinner) => T): T = {
      if (responses.revealed.isEmpty) {
        picking(czar, call, responses.hidden.get)
      } else {
        if (responses.revealed.get.playedByAndWinner.isEmpty) {
          judging(czar, call, responses.revealed.get.cards)
        } else {
          finished(czar, call, responses.revealed.get.cards, responses.revealed.get.playedByAndWinner.get)
        }
      }
    }
  }

  case class FinishedRound(czar: Player.Id, call: Call, cards: List[List[Response]], playedByAndWinner: PlayedByAndWinner)

  case class Responses(hidden: Option[Int], revealed: Option[Revealed]) {
    require(hidden.isDefined ^ revealed.isDefined, "Only one of the count or cards should be provided.")
  }
  object Responses {
    def hidden(count: Int): Responses = Responses(Some(count), None)
    def revealed(revealed: Revealed): Responses = Responses(None, Some(revealed))
  }

  case class Revealed(cards: List[List[Response]], playedByAndWinner: Option[PlayedByAndWinner])

  case class PlayedByAndWinner(playedBy: List[Player.Id], winner: Player.Id)

  case class Hand(hand: List[Response])
  object Hand {
    val size: Int = 10
    val extraDrawAfter: Int = 2
  }

  object Formatters {
    implicit val callFormat: Format[Call] = Json.format[Call]
    implicit val responseFormat: Format[Response] = Json.format[Response]
    implicit val playedByAndWinnerFormat: Format[PlayedByAndWinner] = Json.format[PlayedByAndWinner]
    implicit val revealedFormat: Format[Revealed] = Json.format[Revealed]
    implicit val responsesFormat: Format[Responses] = Json.format[Responses]
    implicit val roundFormat: Format[Round] = Json.format[Round]
    implicit val finishedRoundFormat: Format[FinishedRound] = Json.format[FinishedRound]
    implicit val deckInfoFormat: Format[DeckInfo] = Json.format[DeckInfo]
    implicit val configFormat: Format[Config] = Json.format[Config]
    implicit val handFormat: Format[Hand] = Json.format[Hand]
  }

  private def intersperse[A](a : List[A], b : List[A]): List[A] = a match {
    case first :: rest => first :: intersperse(b, rest)
    case _ => b
  }
}
