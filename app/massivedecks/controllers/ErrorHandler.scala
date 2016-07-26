package massivedecks.controllers

import java.net.URLEncoder
import java.nio.charset.StandardCharsets
import javax.inject.{Inject, Singleton}

import scala.concurrent.Future

import play.api.http.ContentTypes._
import play.api.http.HttpErrorHandler
import play.api.mvc.Results._
import play.api.mvc._
import play.api.Logger
import massivedecks.Config

@Singleton
class ErrorHandler @Inject()(getConfig: Config.Factory) extends HttpErrorHandler {

  def onClientError(request: RequestHeader, statusCode: Int, rawMessage: String) = Future.successful {
    val config = getConfig(request)
    val (message, description) = statusCode match {
      case 400 => ("Bad Request", "there was a problem with the request you made")
      case 403 => ("Forbidden", ",you are not able to access the resource you requested")
      case 404 => ("Not Found", "the page you tried to access doesn't seem to exist")
      case _ => ("Client Error", "there was a problem with the request you made")
    }
    NotFound(views.html.error(
      config.url, config.version, statusCode, message, description,
        bugReportBody(config, request.path, s"$statusCode", rawMessage))).as(HTML)
  }

  def onServerError(request: RequestHeader, exception: Throwable): Future[Result] = Future.successful {
    val config = getConfig(request)
    val description = "the server had a problem trying to handle your request"
    Logger.error(exception.getMessage)
    NotFound(views.html.error(
      config.url, config.version, 500, "Server Error", description,
        bugReportBody(config, request.path, exception.getClass.getSimpleName, exception.getMessage))).as(HTML)
  }

  def bugReportBody(config: Config, path: String, error: String, detail: String) = {
    val extra = if (detail == null || detail.isEmpty) "" else s"\n\nDetail:\n\t${detail.take(1000)}"
    val v = config.version
    val version = if (v.isEmpty) "Not Specified" else v
    val text =
      (s"I was [a short explanation of what you were doing] when I got sent to '$path' and got a '$error' error.$extra"
       ++ s"\n\nApplication Info:\n\tVersion: $version\n\tURL: ${config.url}")
    URLEncoder.encode(text, StandardCharsets.UTF_8.name())
  }

}
