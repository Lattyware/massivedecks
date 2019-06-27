import { Action } from "../../../action";
import * as event from "../../../event";
import * as publicSet from "../../../events/lobby-event/configured/public-set";
import { Handler } from "../../handler";
import * as configure from "../configure";

/**
 * Set (or unset) the password for the lobby.
 */
export interface SetPublic extends configure.Base {
  action: NameType;
  public: boolean;
}

type NameType = "SetPublic";
const name: NameType = "SetPublic";

/**
 * Check if an action is an change decks action.
 * @param action The action to check.
 */
export const is = (action: Action): action is SetPublic =>
  action.action === name;

export const handle: Handler<SetPublic> = (auth, lobby, action) => {
  const config = lobby.config;
  if (action.public !== config.public) {
    const version = config.version + 1;
    const resultEvent = publicSet.of(version.toString(), action.public);
    config.public = action.public;
    config.version = version;
    return { lobby, events: [event.targetAll(resultEvent)] };
  } else {
    return {};
  }
};
