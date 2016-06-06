package models.massivedecks

import models.massivedecks.Game.FinishedRound
import play.api.libs.json.{Json, Writes}
import models.massivedecks.Player.Formatters._
import models.massivedecks.Game.Formatters._
import models.massivedecks.Lobby.Formatters._

/**
  * Events represent a change in the state of the game. These get send via websocket to the client.
  */
sealed trait Event
object Event {
  case class Sync(lobbyAndHand: Lobby.LobbyAndHand) extends Event

  case class PlayerJoin(player: Player) extends Event
  case class PlayerStatus(player: Player.Id, status: Player.Status) extends Event
  case class PlayerLeft(player: Player.Id) extends Event
  case class PlayerDisconnect(player: Player.Id) extends Event
  case class PlayerReconnect(player: Player.Id) extends Event
  case class PlayerScoreChange(player: Player.Id, newScore: Int) extends Event

  case class HandChange(hand: Game.Hand) extends Event

  case class RoundStart(czar: Player.Id, call: Game.Call) extends Event
  case class RoundPlayed(playedCards: Int) extends Event
  case class RoundJudging(playedCards: List[List[Game.Response]]) extends Event
  case class RoundEnd(finishedRound: FinishedRound) extends Event

  case class GameStart() extends Event
  case class GameEnd() extends Event

  case class ConfigChange(config: Game.Config) extends Event

  object Formatters {
    implicit val formatSync = Json.format[Sync]

    implicit val formatPlayerJoin = Json.format[PlayerJoin]
    implicit val formatPlayerStatus = Json.format[PlayerStatus]
    implicit val formatPlayerLeft = Json.format[PlayerLeft]
    implicit val formatPlayerDisconnect = Json.format[PlayerDisconnect]
    implicit val formatPlayerReconnect = Json.format[PlayerReconnect]
    implicit val formatPlayerScoreChange = Json.format[PlayerScoreChange]

    implicit val formatHandChange = Json.format[HandChange]

    implicit val formatRoundStart = Json.format[RoundStart]
    implicit val formatRoundPlayed = Json.format[RoundPlayed]
    implicit val formatRoundJudging = Json.format[RoundJudging]
    implicit val formatRoundEnd = Json.format[RoundEnd]

    implicit val writeGameStart = Writes[GameStart] { _ => Json.obj() }
    implicit val writeGameEnd = Writes[GameEnd] { _ => Json.obj() }

    implicit val formatConfigChange = Json.format[ConfigChange]
  }
}
