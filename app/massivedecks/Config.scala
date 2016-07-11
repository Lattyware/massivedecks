package massivedecks

import play.Play
import play.api.mvc.RequestHeader

object Config {
  val base = Play.application().configuration()

  def getString(key: String) = Option(base.getString(key))

  def apply(request: RequestHeader) = new Config(request)
}
class Config(request: RequestHeader) {
  import Config._

  def protocol = getString("md_protocol").getOrElse {
    request.headers.get("X-Forwarded-Proto") match {
      case Some(proto) => proto
      case None => if (request.secure) { "https" } else { "http" }
    }
  }
  def host = getString("md_host").getOrElse(request.host)
  def path = getString("md_path").getOrElse("/")

  def url = s"$protocol://$host$path"

  def version = getString("md_release_version").getOrElse {
    getString("md_git_version").map(v => s"${v.take(7)}-dev").getOrElse("")
  }
}
