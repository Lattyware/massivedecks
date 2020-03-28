import { InboundPort } from "../elm/MassiveDecks";

export const flags = () => ({ settings: SettingsStorage.load() });

export const register = (storeSettings: InboundPort<object>) => {
  storeSettings.subscribe(SettingsStorage.save);
};

/**
 * Settings storage/retrieval in local storage.
 */
class SettingsStorage {
  static readonly storage = window.localStorage;
  static readonly key: string = "settings";

  /**
   * Load settings from local storage.
   */
  static load() {
    const rawSettings = SettingsStorage.storage.getItem(SettingsStorage.key);
    return rawSettings ? JSON.parse(rawSettings) : undefined;
  }

  /**
   * Save the given settings to local storage.
   * @param settings The settings.
   */
  static save(settings: object) {
    SettingsStorage.storage.setItem(
      SettingsStorage.key,
      JSON.stringify(settings)
    );
  }
}
