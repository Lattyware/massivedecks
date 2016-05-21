package controllers.massivedecks.exceptions

import play.api.libs.json.Json.JsValueWrapper

case class BadRequestException(message: String) extends Exception
object BadRequestException {
  def json(error: String, args: (String, JsValueWrapper)*): BadRequestException =
    new BadRequestException(JsonError.of(error, args: _*))

  def verify(requirement: Boolean, error: String, args: (String, JsValueWrapper)*): Unit = {
    if (!requirement) {
      throw BadRequestException.json(error, args: _*)
    }
  }
}
