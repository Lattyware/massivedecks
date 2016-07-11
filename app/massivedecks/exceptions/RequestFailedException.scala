package massivedecks.exceptions

import massivedecks.models.Errors.ErrorDetails
import play.api.http.Status

/**
  * An exception representing a request that failed due to a request being made by the server failing.
  * Represents a 502 error.
  *
  * @param details The details of the error to be given to the requester.
  */
case class RequestFailedException(details: ErrorDetails) extends RequestException {
  val statusCode = Status.BAD_GATEWAY
}
object RequestFailedException {
  /**
    * Verify the given requirement - if not met, throw a RequestFailedException.
    * @param requirement The requirement to verify
    * @param details The details.
    */
  def verify(requirement: Boolean, details: ErrorDetails): Unit = {
    if (!requirement) {
      throw RequestFailedException(details)
    }
  }
}
