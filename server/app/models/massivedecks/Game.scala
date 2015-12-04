package models.massivedecks

import play.api.libs.json._

import models.massivedecks.Player.Formatters._
import models.massivedecks.Lobby.Formatters._

object Game {

  sealed trait Card

  case class Call(parts: List[String]) extends Card {
    require(parts.length > 1, "A call must have at least one slot.")

    def slots: Int = parts.length - 1

    def withResponses(responses: List[Response]): String =
      intersperse(parts, responses.map(response => response.text)).mkString("")
  }

  case class Response(text: String) extends Card

  case class Config(deckIds: List[String])

  case class Round(czar: Player.Id, call: Call, responses: Responses) {
    require(responses.cards.isEmpty || responses.cards.get.forall(playerResponses => playerResponses.length == call.slots),
      "Plays for a call must have a number of responses equal to the number of spots in the call.")
  }

  case class Responses(count: Option[Int], cards: Option[List[List[Response]]]) {
    require(count.isDefined ^ cards.isDefined, "Only one of the count or cards should be provided.")

    def asEither: Either[Int, List[List[Response]]] =
      Either.cond(count.isEmpty, cards.get, count.get)
  }
  object Responses {
    def fromEither(responses: Either[Int, List[List[Response]]]) =
      Responses(responses.left.toOption, responses.right.toOption)

    def count(count: Int): Responses = Responses(Some(count), None)
    def cards(cards: List[List[Response]]): Responses = Responses(None, Some(cards))
  }

  case class Hand(hand: List[Response])
  object Hand {
    val size: Int = 7
  }

  object Formatters {
    implicit val callFormat: Format[Call] = Format(
      Reads(response => response.validate[List[String]].map(Call.apply)),
      Writes(response => JsArray(response.parts.map(JsString)))
    )
    implicit val responseFormat: Format[Response] = Format(
      Reads(response => response.validate[String].map(Response)),
      Writes(response => JsString(response.text))
    )
    implicit val responsesFormat: Format[Responses] = Json.format[Responses]
    implicit val roundFormat: Format[Round] = Json.format[Round]
    implicit val configFormat: Format[Config] = Json.format[Config]
    implicit val handFormat: Format[Hand] = Json.format[Hand]
  }

  private def intersperse[A](a : List[A], b : List[A]): List[A] = a match {
    case first :: rest => first :: intersperse(b, rest)
    case _             => b
  }
}
