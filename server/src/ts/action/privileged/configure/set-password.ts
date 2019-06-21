import { Action } from "../../../action";
import * as event from "../../../event";
import * as passwordSet from "../../../events/lobby-event/configured/password-set";
import { PasswordSet } from "../../../events/lobby-event/configured/password-set";
import { Handler } from "../../handler";
import * as configure from "../configure";

/**
 * Set (or unset) the password for the lobby.
 */
export interface SetPassword extends configure.Base {
  action: NameType;
  /**
   * @maxLength 100
   * @minLength 1
   */
  password?: string;
}

type NameType = "SetPassword";
const name: NameType = "SetPassword";

/**
 * Check if an action is an change decks action.
 * @param action The action to check.
 */
export const is = (action: Action): action is SetPassword =>
  action.action === name;

export const handle: Handler<SetPassword> = (auth, lobby, action) => {
  const config = lobby.config;
  if (action.password !== config.password) {
    const version = config.version + 1;
    const resultEvent: PasswordSet = {
      event: "PasswordSet",
      version: version.toString()
    };
    if (action.password !== undefined) {
      config.password = action.password;
      resultEvent.password = action.password;
    } else {
      delete config.password;
    }
    config.version = version;
    const events = event.targetByPrivilege(resultEvent, passwordSet.censor);
    return { lobby, events: events };
  } else {
    return {};
  }
};
