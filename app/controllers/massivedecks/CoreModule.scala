package controllers.massivedecks

import com.google.inject.AbstractModule

/**
  * Guice module for the application.
  */
class CoreModule extends AbstractModule {
  def configure = {
    bind(classOf[LobbyStore]).to(classOf[InMemoryStore])
  }
}
