package massivedecks

import scala.concurrent.duration.FiniteDuration
import scala.concurrent.{Await, Future, Promise}
import scala.util.Try

/**
  * Utility functions.
  */
object Util {

  /**
    * Wait for the given amount of time.
    *
    * @param duration The time to wait for.
    * @return A future to wait on.
    */
  def wait(duration: FiniteDuration): Try[Future[Nothing]] = Try(Await.ready(Promise().future, duration))

}
