package controllers.massivedecks.exceptions

import play.api.libs.json.Json.JsValueWrapper

/**
  * An exception representing a request that failed due to a request being made by the server failing.
  * Represents a 502 error.
  *
  * @param message The message. Should be JSON - the the companion class for helpers.
  */
case class BadRequestException(message: String) extends Exception
object BadRequestException {
  /**
    * Generate a BadRequestException with a JSON error message.
    * @param error The name of the error.
    * @param args Any key/value pairs to add to the error.
    * @return The exception
    */
  def json(error: String, args: (String, JsValueWrapper)*): BadRequestException =
    new BadRequestException(JsonError.of(error, args: _*))

  /**
    * Verify the given requirement - if not met, throw the given BadRequestException with a JSON error message.
    * @param requirement The requirement to verify
    * @param error The name of the error.
    * @param args Any key/value pairs to add to the error.
    */
  def verify(requirement: Boolean, error: String, args: (String, JsValueWrapper)*): Unit = {
    if (!requirement) {
      throw BadRequestException.json(error, args: _*)
    }
  }
}
