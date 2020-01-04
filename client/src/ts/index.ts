import "./weightless";
import { Client as CastClient } from "./chromecast";
import { Settings } from "../elm/MassiveDecks";
import { ServerConnection } from "./server-connection";
import { Speech } from "./speech";
import { NotificationManager } from "./notification-manager";

/**
 * Settings storage/retrieval in local storage.
 */
class SettingsStorage {
  static readonly storage = window.localStorage;
  static readonly key: string = "settings";
  static readonly default: Settings = {
    tokens: [],
    lastUsedName: null,
    recentDecks: [],
    chosenLanguage: null
  };

  /**
   * Load settings from local storage.
   */
  static load() {
    const rawSettings = SettingsStorage.storage.getItem(SettingsStorage.key);
    return rawSettings ? JSON.parse(rawSettings) : SettingsStorage.default;
  }

  /**
   * Save the given settings to local storage.
   * @param settings The settings.
   */
  static save(settings: Settings) {
    SettingsStorage.storage.setItem(
      SettingsStorage.key,
      JSON.stringify(settings)
    );
  }
}

// This lets us chunk off our elm code separately, which is important so we can
// use optimisations that will only be valid on pure code.
import(/* webpackChunkName: "massive-decks" */ "../elm/MassiveDecks").then(
  ({ Elm: elm }) => {
    const app = elm.MassiveDecks.init({
      flags: {
        settings: SettingsStorage.load(),
        browserLanguages: navigator.languages.concat()
      }
    });

    // Settings
    app.ports.storeSettings.subscribe((settings: Settings) =>
      SettingsStorage.save(settings)
    );

    new ServerConnection(app.ports.serverRecv, app.ports.serverSend);

    new CastClient(app.ports.tryCast, app.ports.castStatus);

    app.ports.copyText.subscribe(async (id: string) => {
      const textField = document.getElementById(id);
      if (textField !== null && textField instanceof HTMLInputElement) {
        textField.select();
        const value = textField.value;
        textField.setSelectionRange(0, value.length);
        try {
          await navigator.clipboard.writeText(value);
        } catch (err) {
          document.execCommand("copy");
        }
      }
    });

    if ("speechSynthesis" in window) {
      new Speech(app.ports.speechVoices, app.ports.speechCommands);
    }

    new NotificationManager(
      app.ports.notificationState,
      app.ports.notificationCommands
    );
  }
);
