import { Action } from "../action";
import { Handler } from "./handler";
import * as kick from "./privileged/kick";

/**
 * A player asks to leave the game.
 */
export interface Leave {
  action: "Leave";
}

type NameType = "Leave";
const name: NameType = "Leave";

export const is = (action: Action): action is Leave => action.action === name;

export const handle: Handler<Leave> = (auth, lobby, action, server) =>
  kick.removeUser(auth.uid, lobby, server, "Left");
