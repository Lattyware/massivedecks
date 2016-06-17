package controllers.massivedecks.exceptions

import play.api.libs.json.Json.JsValueWrapper

/**
  * An exception representing a request that failed due to the request not being authorized.
  * Represents a 403 error.
  *
  * @param message The message. Should be JSON - the the companion class for helpers.
  */
case class ForbiddenException(message: String) extends Exception
object ForbiddenException {
  /**
    * Generate a ForbiddenException with a JSON error message.
    * @param error The name of the error.
    * @param args Any key/value pairs to add to the error.
    * @return The exception
    */
  def json(error: String, args: (String, JsValueWrapper)*): ForbiddenException =
    new ForbiddenException(JsonError.of(error, args: _*))

  /**
    * Verify the given requirement - if not met, throw the given ForbiddenException with a JSON error message.
    * @param requirement The requirement to verify
    * @param error The name of the error.
    * @param args Any key/value pairs to add to the error.
    */
  def verify(requirement: Boolean, error: String, args: (String, JsValueWrapper)*): Unit = {
    if (!requirement) {
      throw ForbiddenException.json(error, args: _*)
    }
  }
}
