import {InboundPort} from "../elm/MassiveDecks";

export const flags = () => ({ browserLanguages: navigator.languages.concat() });

export function register(langChanged: InboundPort<string>) {
  langChanged.subscribe(LanguageManager.langChanged);
}

class LanguageManager {
  public static async langChanged(lang: string) {
    document.documentElement.lang = lang;
  }
}
