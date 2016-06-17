package controllers.massivedecks.exceptions

import play.api.libs.json.Json.JsValueWrapper

/**
  * An exception representing a request that failed due to the requested resource not being found.
  * Represents a 404 error.
  *
  * @param message The message. Should be JSON - the the companion class for helpers.
  */
case class NotFoundException(message: String) extends Exception
object NotFoundException {
  /**
    * Generate a NotFoundException with a JSON error message.
    * @param error The name of the error.
    * @param args Any key/value pairs to add to the error.
    * @return The exception
    */
  def json(error: String, args: (String, JsValueWrapper)*): NotFoundException =
    new NotFoundException(JsonError.of(error, args: _*))
}
