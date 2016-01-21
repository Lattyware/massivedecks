package controllers.massivedecks.game

import play.api.libs.json.Json
import play.api.libs.json.Json.JsValueWrapper

object JsonError {
  def of(error: String, args: (String, JsValueWrapper)*): String = {
    val fields = List[(String, JsValueWrapper)]("error" -> error) ++ args
    Json.stringify(Json.obj(fields: _*))
  }
}
