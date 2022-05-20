import { InvalidActionError } from "../../errors/validation.js";
import * as Event from "../../event.js";
import * as PrivilegeChanged from "../../events/lobby-event/privilege-changed.js";
import type * as Lobby from "../../lobby.js";
import type * as User from "../../user.js";
import type * as Handler from "../handler.js";
import type { Privileged } from "../privileged.js";
import * as Actions from "./../actions.js";

/**
 * A privileged user asks to change the privilege of another user.
 */
export interface SetPrivilege {
  action: "SetPrivilege";
  user: User.Id;
  privilege: User.Privilege;
}

class SetPrivilegeActions extends Actions.Implementation<
  Privileged,
  SetPrivilege,
  "SetPrivilege",
  Lobby.Lobby
> {
  protected readonly name = "SetPrivilege";

  protected handle: Handler.Custom<SetPrivilege, Lobby.Lobby> = (
    auth,
    lobby,
    action,
  ) => {
    const user = lobby.users[action.user] as User.User;

    if (user.control === "Computer") {
      throw new InvalidActionError("Can't do this with AIs.");
    }

    const privilege = action.privilege;

    if (user.privilege !== privilege) {
      user.privilege = privilege;
      return {
        lobby,
        events: [Event.targetAll(PrivilegeChanged.of(action.user, privilege))],
      };
    }
    return {};
  };
}
export const actions = new SetPrivilegeActions();
