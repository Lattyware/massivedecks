package models.massivedecks

import play.api.libs.json._

object Player {

  case class Id(id: Int) extends AnyVal

  sealed trait Status {
    val name: String
  }
  object Status {
    private val types = List(NotPlayed, Played, Czar, Disconnected, Left, Neutral)
    val fromName: Map[String, Status] = (for (status <- types) yield status.name -> status).toMap
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
  case object Disconnected extends Status {
    val name = "disconnected"
  }
  case object Left extends Status {
    val name = "left"
  }
  case object Neutral extends Status {
    val name = "neutral"
  }

  case class Player(id: Id, name: String, status: Status, score: Int) {
    require(!name.isEmpty, "Name can't be empty!")
  }

  case class Secret(id: Id, secret: String)

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
