package massivedecks.models

import play.api.libs.json.Json

/**
  * Errors models.
  */
object Errors {
  trait ErrorDetails {
    def error: String
    def toJson(): String
  }

  trait SimpleErrorDetails extends ErrorDetails {
    def toJson() = Json.obj("error" -> error).toString()
  }

  case class LobbyNotFound(error: String = "lobby-not-found") extends SimpleErrorDetails
  case class InvalidCommand(command: String, error: String = "invalid-command") extends ErrorDetails {
    def toJson() = Json.obj(
      "error" -> error,
      "command" -> command
    ).toString()
  }
  case class InvalidName(error: String = "invalid-name") extends SimpleErrorDetails
  case class NameInUse(error: String = "name-in-use") extends SimpleErrorDetails
  case class BadlyFormedSecret(error: String = "badly-formed-secret") extends SimpleErrorDetails
  case class SecretWrongOrNotAPlayer(error: String = "secret-wrong-or-not-a-player") extends SimpleErrorDetails
  case class PasswordWrong(error: String = "password-wrong") extends SimpleErrorDetails
  case class NotAPlayer(error: String = "not-a-player") extends SimpleErrorDetails
  case class NotBeingSkipped(error: String = "not-being-skipped") extends SimpleErrorDetails
  case class AlreadyLeftGame(error: String = "already-left-game") extends SimpleErrorDetails
  case class CardcastTimeout(error: String = "cardcast-timeout") extends SimpleErrorDetails
  case class GameInProgress(error: String = "game-in-progress") extends SimpleErrorDetails
  case class NotEnoughPlayers(required: Int, error: String = "not-enough-players") extends ErrorDetails {
    def toJson() = Json.obj(
      "error" -> error,
      "required" -> required
    ).toString()
  }
  case class PlayersMustBeSkippable(error: String = "players-must-be-skippable") extends SimpleErrorDetails
  case class RuleNotEnabled(error: String = "rule-not-enabled") extends SimpleErrorDetails
  case class NoGameInProgress(error: String = "no-game-in-progress") extends SimpleErrorDetails
  case class NotInRound(error: String = "not-in-round") extends SimpleErrorDetails
  case class AlreadyPlayed(error: String = "already-played") extends SimpleErrorDetails
  case class AlreadyJudging(error: String = "already-judging") extends SimpleErrorDetails
  case class InvalidCardId(error: String = "invalid-card-id") extends SimpleErrorDetails
  case class WrongNumberOfCardsPlayed(got: Int, expected: Int, error: String = "wrong-number-of-cards-played") extends ErrorDetails {
    def toJson() = Json.obj(
      "error" -> error,
      "got" -> got,
      "expected" -> expected
    ).toString()
  }
  case class NotCzar(error: String = "not-czar") extends SimpleErrorDetails
  case class NotJudging(error: String = "not-judging") extends SimpleErrorDetails
  case class NoSuchPlayedCards(error: String = "no-such-played-cards") extends SimpleErrorDetails
  case class AlreadyJudged(error: String = "already-judged") extends SimpleErrorDetails
  case class NotEnoughPoints(error: String = "not-enough-points") extends SimpleErrorDetails
  case class InvalidDeckConfiguration(reason: String, error: String = "invalid-deck-configuration") extends ErrorDetails {
    def toJson() = Json.obj(
      "error" -> error,
      "reason" -> reason
    ).toString()
  }
  case class DeckNotFound(error: String = "deck-not-found") extends SimpleErrorDetails
  case class NotOwner(error: String = "not-owner") extends SimpleErrorDetails

}
