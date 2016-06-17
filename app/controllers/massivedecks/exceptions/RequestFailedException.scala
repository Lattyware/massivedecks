package controllers.massivedecks.exceptions

import play.api.libs.json.Json.JsValueWrapper

/**
  * An exception representing a request that failed due to the request not being authorized.
  * Represents a 403 error.
  *
  * @param message The message. Should be JSON - the the companion class for helpers.
  */
case class RequestFailedException(message: String) extends Exception
object RequestFailedException {
  /**
    * Generate a RequestFailedException with a JSON error message.
    * @param error The name of the error.
    * @param args Any key/value pairs to add to the error.
    * @return The exception
    */
  def json(error: String, args: (String, JsValueWrapper)*): RequestFailedException =
    new RequestFailedException(JsonError.of(error, args: _*))
}
