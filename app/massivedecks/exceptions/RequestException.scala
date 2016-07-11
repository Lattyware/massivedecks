package massivedecks.exceptions

import massivedecks.models.Errors.ErrorDetails

trait RequestException extends Exception {
  def statusCode: Int
  def details: ErrorDetails
}
