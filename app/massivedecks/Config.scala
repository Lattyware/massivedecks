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

  def requestProtocol = request.headers.get("X-Forwarded-Proto") match {
    case Some(proto) => proto
    case None => if (request.secure) { "https" } else { "http" }
  }

  def protocol = canonicalProtocol.getOrElse(requestProtocol)
  def host = canonicalHost.getOrElse(request.host)
  def path = canonicalPath.getOrElse("/")

  def url = s"$protocol://$host$path"

  def canonicalProtocol = getString("md_protocol")
  def canonicalHost = getString("md_host")
  def canonicalPath = getString("md_path")

  def requestIsCanonical = (canonicalProtocol.forall(proto => proto == requestProtocol)
    && canonicalHost.forall(host => host == request.host)
    && canonicalPath.forall(path => request.path.startsWith(path)))

  def canonicalUrlTo(path: String) = s"$protocol://$host$path"

  def version = getString("md_release_version").getOrElse {
    getString("md_git_version").map(v => s"${v.take(7)}-dev").getOrElse("")
  }
}
