package massivedecks.exceptions

import massivedecks.models.Errors.ErrorDetails
import play.api.http.Status

/**
  * An exception representing a request that failed due to the request being faulty.
  * Represents a 400 error.
  *
  * @param details The details of the error to be given to the requester.
  */
case class BadRequestException(details: ErrorDetails) extends RequestException {
  val statusCode = Status.BAD_REQUEST
}
object BadRequestException {
  /**
    * Verify the given requirement - if not met, throw a BadRequestException.
    * @param requirement The requirement to verify
    * @param details The details.
    */
  def verify(requirement: Boolean, details: ErrorDetails): Unit = {
    if (!requirement) {
      throw BadRequestException(details)
    }
  }
}
