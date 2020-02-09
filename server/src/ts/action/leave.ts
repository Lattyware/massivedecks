import * as Action from "../action";
import * as Lobby from "../lobby";
import * as Actions from "./actions";
import * as Handler from "./handler";
import * as Kick from "./privileged/kick";

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
    server
  ) => Kick.removeUser(auth.uid, lobby, server, "Left");
}

export const actions = new LeaveActions();
