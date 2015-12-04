package controllers.massivedecks

import com.google.inject.AbstractModule
import controllers.massivedecks.game.{Game, Store}
import play.api.libs.concurrent.AkkaGuiceSupport

/**
  * Guice module for the application.
  */
class CoreModule extends AbstractModule with AkkaGuiceSupport {
  def configure = {
    bindActor[Store]("store")
    bindActorFactory[Game, Game.Factory]
  }
}
