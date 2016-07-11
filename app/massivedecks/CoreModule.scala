package massivedecks

import com.google.inject.AbstractModule
import massivedecks.stores.{InMemoryStore, LobbyStore}

/**
  * Guice module for the application.
  */
class CoreModule extends AbstractModule {
  def configure = {
    bind(classOf[LobbyStore]).to(classOf[InMemoryStore])
  }
}
