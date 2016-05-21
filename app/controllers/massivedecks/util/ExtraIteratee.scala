package controllers.massivedecks.util

import play.api.libs.iteratee.{Cont, Done, Input, Iteratee}

object ExtraIteratee {

  def onFirstGivingWhenDone[E](onFirst: E => (() => Unit)): Iteratee[E, Unit] = {
    def cont: Iteratee[E, Unit] = Cont {
      case Input.EOF =>
        Done((), Input.EOF)
      case Input.El(i) =>
        whenDone(onFirst(i))
      case Input.Empty =>
        cont
    }
    cont
  }

  def whenDone[E](whenDone: () => Unit): Iteratee[E, Unit] = {
    def cont: Iteratee[E, Unit] = Cont {
      case Input.EOF =>
        whenDone()
        Done((), Input.EOF)
      case _ =>
        cont
    }
    cont
  }

}
