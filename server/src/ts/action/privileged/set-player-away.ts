import { Action } from "../../action";
import * as user from "../../user";
import { Handler } from "../handler";

/**
 * A privileged user asks to set a given player as away.
 */
export interface SetPlayerAway {
  action: "SetPlayerAway";
  user: user.Id;
}

type NameType = "SetPlayerAway";
const name: NameType = "SetPlayerAway";

export const is = (action: Action): action is SetPlayerAway =>
  action.action === name;

export const handle: Handler<SetPlayerAway> = (auth, lobby, action) => ({});
