package massivedecks.controllers

import javax.inject.Inject

import play.api.libs.json.Json
import play.api.mvc.{Action, Controller}
import play.api.cache.Cached
import play.api.Play.current

import massivedecks.Config

class Pages @Inject() (cached: Cached, getConfig: Config.Factory) extends Controller {

  def index() = Action { request =>
    val config = getConfig(request)
    if (!config.requestIsCanonical) {
      Redirect(config.canonicalUrlTo(request.path))
    } else {
      Ok(views.html.index(config.url, config.version)).as(HTML)
    }
  }

  def manifest() = cached("manifest")(Action { request =>
    val config = getConfig(request)
    val json = Json.obj(
      "name" -> "Massive Decks",
      "description" -> "An online party game inspired by Cards Against Humanity.",
      "icons" -> Json.arr(
        Json.obj(
          "src" -> controllers.routes.Assets.versioned("icon.png").url,
          "sizes" -> "192x192",
          "type" -> "image/png",
          "density" -> 4.0
        )
      ),
      "lang" -> "en",
      "start_url" -> config.path,
      "display" -> "standalone",
      "orientation" -> "portrait-primary",
      "background_color" -> "#e5e5e5",
      "theme_color" -> "#2196F3"
    )
    Ok(json.toString).as(withCharset("application/manifest+json"))
  })

}
