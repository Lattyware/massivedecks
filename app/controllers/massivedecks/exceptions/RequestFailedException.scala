package controllers.massivedecks.exceptions

import play.api.libs.json.Json.JsValueWrapper

case class RequestFailedException(message: String) extends Exception
object RequestFailedException {
  def json(error: String, args: (String, JsValueWrapper)*): RequestFailedException =
    new RequestFailedException(JsonError.of(error, args: _*))
}
