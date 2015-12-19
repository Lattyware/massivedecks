package controllers.massivedecks.game

case class BadRequestException(message: String) extends Exception
object BadRequestException {
  def verify(requirement: Boolean, message: => String): Unit = {
    if (!requirement) {
      throw new BadRequestException(message)
    }
  }
}
