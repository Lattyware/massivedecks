import type * as Action from "../action.js";
import type * as Lobby from "../lobby.js";
import * as Actions from "./actions.js";
import type * as Handler from "./handler.js";
import * as Kick from "./privileged/kick.js";

/**
 * A player asks to leave the game.
 */
export interface Leave {
  action: "Leave";
}

class LeaveActions extends Actions.Implementation<
  Action.Action,
  Leave,
  "Leave",
  Lobby.Lobby
> {
  protected readonly name = "Leave";

  protected handle: Handler.Custom<Leave, Lobby.Lobby> = (
    auth,
    lobby,
    action,
    server,
  ) => Kick.removeUser(auth.uid, lobby, server, "Left");
}

export const actions = new LeaveActions();
