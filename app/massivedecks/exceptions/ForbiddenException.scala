package massivedecks.exceptions

import massivedecks.models.Errors.ErrorDetails
import play.api.http.Status

/**
  * An exception representing a request that failed due to the request not being authorized.
  * Represents a 403 error.
  *
  * @param details The details of the error to be given to the requester.
  */
case class ForbiddenException(details: ErrorDetails) extends RequestException {
  val statusCode = Status.FORBIDDEN
}
object ForbiddenException {
  /**
    * Verify the given requirement - if not met, throw a ForbiddenException.
    * @param requirement The requirement to verify
    * @param details The details.
    */
  def verify(requirement: Boolean, details: ErrorDetails): Unit = {
    if (!requirement) {
      throw ForbiddenException(details)
    }
  }
}
