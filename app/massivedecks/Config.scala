package massivedecks

import javax.inject.Inject

import play.api.Configuration
import play.api.mvc.RequestHeader

object Config {
  /**
    * Factory for dependency injection.
    */
  class Factory @Inject()(base: Configuration) {
    def apply(request: RequestHeader) = new Config(base, request)
  }
}
class Config(base: Configuration, request: RequestHeader) {
  def getString(key: String) = base.getString(key)

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
