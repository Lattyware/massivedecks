import { Action } from "../../action";
import * as gameAction from "../game-action";

/**
 * A player asks to set themself as away.
 */
export interface SetAway {
  action: "SetAway";
}

type NameType = "SetAway";
const name: NameType = "SetAway";

export const is = (action: Action): action is SetAway => action.action === name;

export const handle: gameAction.Handler<SetAway> = (
  auth,
  lobby,
  action
) => ({});
