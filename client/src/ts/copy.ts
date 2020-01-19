import { InboundPort } from "../elm/MassiveDecks";

export function register(copy: InboundPort<string>) {
  copy.subscribe(ClipboardManager.copy);
}

class ClipboardManager {
  public static async copy(id: string) {
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
  }
}
