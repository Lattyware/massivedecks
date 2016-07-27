package massivedecks.models

import play.api.libs.json._
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

  case class Config(decks: List[DeckInfo], houseRules: Set[String], password: Option[String])

  sealed trait State {
    def gameState: String
  }
  object State {
    case class Configuring() extends State {
      override val gameState = "configuring"
    }
    case class Playing(round: Round) extends State {
      override val gameState = "playing"
    }
    case class Finished() extends State {
      override val gameState = "finished"
    }
  }

  case class Round(czar: Player.Id, call: Call, state: Round.State)
  object Round {
    sealed trait State {
      def afterTimeLimit: Boolean
      def roundState: String

      def isPlaying: Boolean = this.isInstanceOf[State.Playing]
      def isJudging: Boolean = this.isInstanceOf[State.Judging]
      def isFinished: Boolean = this.isInstanceOf[State.Finished]
    }
    object State {
      case class Playing(override val afterTimeLimit: Boolean, numberPlayed: Int) extends State {
        override val roundState = "playing"
      }

      case class Judging(override val afterTimeLimit: Boolean, cards: List[List[Response]]) extends State {
        override val roundState = "judging"
      }

      case class Finished(cards: List[List[Response]], playedByAndWinner: PlayedByAndWinner) extends State {
        override val roundState = "finished"
        override val afterTimeLimit = false
      }
    }
    case class Finished(czar: Player.Id, call: Call, state: Round.State.Finished)
  }

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
    implicit val deckInfoFormat: Format[DeckInfo] = Json.format[DeckInfo]
    implicit val configFormat: Format[Config] = Json.format[Config]
    implicit val handFormat: Format[Hand] = Json.format[Hand]

    private val playingRoundStateFormat: Format[Round.State.Playing] = Json.format[Round.State.Playing]
    private val judgingRoundStateFormat: Format[Round.State.Judging] = Json.format[Round.State.Judging]
    private val finishedRoundStateFormat: Format[Round.State.Finished] = Json.format[Round.State.Finished]
    implicit val roundStateWrites: Writes[Round.State] = Writes { state: Round.State =>
      (state match {
        case state: Round.State.Playing =>
          playingRoundStateFormat.writes(state)

        case state: Round.State.Judging =>
          judgingRoundStateFormat.writes(state)

        case state: Round.State.Finished =>
          finishedRoundStateFormat.writes(state)
      }).as[JsObject] + ("roundState" -> Json.toJson(state.roundState))
    }
    implicit val roundWrites: Writes[Round] = Json.writes[Round]
    implicit val finishedRoundWrites: Writes[Round.Finished] = Json.writes[Round.Finished]

    private val playingGameStateFormat: Writes[State.Playing] = Json.writes[State.Playing]
    implicit val gameStateWrites: Writes[State] = Writes { state: State =>
      (state match {
        case state: State.Configuring => JsObject(List())
        case state: State.Playing => playingGameStateFormat.writes(state)
        case state: State.Finished => JsObject(List())
      }).as[JsObject] + ("gameState" -> Json.toJson(state.gameState))
    }
  }

  private def intersperse[A](a : List[A], b : List[A]): List[A] = a match {
    case first :: rest => first :: intersperse(b, rest)
    case _ => b
  }
}
