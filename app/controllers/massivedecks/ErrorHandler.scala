package controllers.massivedecks

import java.net.URLEncoder
import java.nio.charset.StandardCharsets
import javax.inject.Singleton;

import scala.concurrent.Future

import play.api.http.ContentTypes._
import play.api.http.HttpErrorHandler
import play.api.mvc.Results._
import play.api.mvc._

@Singleton
class ErrorHandler extends HttpErrorHandler {

  def onClientError(request: RequestHeader, statusCode: Int, rawMessage: String) = Future.successful {
    val config = Config(request)
    val (message, description) = statusCode match {
      case 400 => ("Bad Request", "there was a problem with the request you made")
      case 403 => ("Forbidden", ",you are not able to access the resource you requested")
      case 404 => ("Not Found", "the page you tried to access doesn't seem to exist")
      case _ => ("Client Error", "there was a problem with the request you made")
    }
    NotFound(views.html.massivedecks.error(
      config.url, statusCode, message, description, bugReportBody(request.path, s"$statusCode", rawMessage))).as(HTML)
  }

  def onServerError(request: RequestHeader, exception: Throwable): Future[Result] = Future.successful {
    val config = Config(request)
    val description = "the server had a problem trying to handle your request"
    NotFound(views.html.massivedecks.error(
      config.url, 500, "Server Error", description,
        bugReportBody(request.path, exception.getClass.getSimpleName, exception.getMessage))).as(HTML)
  }

  def bugReportBody(path: String, error: String, detail: String) = {
    val extra = if (detail.isEmpty) "" else "\n\nDetail:\n$detail"
    val text = s"I was [a short explanation of what you were doing] when I got sent to '$path' and got a '$error' error.$extra"
    URLEncoder.encode(text, StandardCharsets.UTF_8.name())
  }

}
