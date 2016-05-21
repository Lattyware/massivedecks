package controllers.massivedecks.exceptions

import play.api.libs.json.Json.JsValueWrapper

case class ForbiddenException(message: String) extends Exception
object ForbiddenException {
  def json(error: String, args: (String, JsValueWrapper)*): ForbiddenException =
    new ForbiddenException(JsonError.of(error, args: _*))

  def verify(requirement: Boolean, error: String, args: (String, JsValueWrapper)*): Unit = {
    if (!requirement) {
      throw ForbiddenException.json(error, args: _*)
    }
  }
}
