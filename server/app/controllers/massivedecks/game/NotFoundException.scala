package controllers.massivedecks.game

import play.api.libs.json.Json.JsValueWrapper

case class NotFoundException(message: String) extends Exception
object NotFoundException {
  def json(error: String, args: (String, JsValueWrapper)*): NotFoundException =
    new NotFoundException(JsonError.of(error, args: _*))
}
