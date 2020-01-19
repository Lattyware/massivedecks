import { InboundPort, Settings } from "../elm/MassiveDecks";

export const flags = () => ({ settings: SettingsStorage.load() });

export const register = (storeSettings: InboundPort<Settings>) => {
  storeSettings.subscribe(SettingsStorage.save);
};

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
