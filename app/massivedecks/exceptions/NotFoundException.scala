package massivedecks.exceptions

import massivedecks.models.Errors.ErrorDetails
import play.api.http.Status

/**
  * An exception representing a request that failed due to the requested resource not being found.
  * Represents a 404 error.
  *
  * @param details The details of the error to be given to the requester.
  */
case class NotFoundException(details: ErrorDetails) extends RequestException {
  val statusCode = Status.NOT_FOUND
}
