package massivedecks.models

import java.util.UUID

import play.api.libs.json._

case class Player(id: Player.Id, name: String, status: Player.Status = Player.Neutral, score: Int = 0, disconnected: Boolean = false, left: Boolean = false) {
  require(!name.isEmpty, "Name can't be empty!")
}
object Player {

  case class Id(id: Int) extends AnyVal

  sealed trait Status {
    val name: String
  }
  object Status {
    private val types = List(NotPlayed, Played, Czar, Ai, Neutral, Skipping)
    val fromName: Map[String, Status] = (for (status <- types) yield status.name -> status).toMap
    val notInRound: Set[Status] = Set(Skipping, Czar)
    val sticky: Set[Status] = Set(Ai, Skipping)
  }
  case object NotPlayed extends Status {
    val name = "not-played"
  }
  case object Played extends Status {
    val name = "played"
  }
  case object Czar extends Status {
    val name = "czar"
  }
  case object Ai extends Status {
    val name = "ai"
  }
  case object Neutral extends Status {
    val name = "neutral"
  }
  case object Skipping extends Status {
    val name = "skipping"
  }

  case class Secret(id: Player.Id, secret: String = UUID.randomUUID().toString)

  object Formatters {
    implicit val idFormat: Format[Id] = Format(
      Reads(num => num.validate[Int].map(Id)), Writes(id => JsNumber(id.id)))
    implicit val statusFormat : Format[Status] = Format(
      Reads(str => str.validate[String].map(Status.fromName)),
      Writes(status => JsString(status.name)))
    implicit val secretFormat: Format[Secret] = Json.format[Secret]
    implicit val playerFormat: Format[Player] = Json.format[Player]
  }
}
