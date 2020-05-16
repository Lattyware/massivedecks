import * as Actions from "./../actions";
import { InvalidActionError } from "../../errors/validation";
import * as Event from "../../event";
import * as PrivilegeChanged from "../../events/lobby-event/privilege-changed";
import * as Lobby from "../../lobby";
import * as User from "../../user";
import * as Handler from "../handler";
import { Privileged } from "../privileged";

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
    action
  ) => {
    const user = lobby.users[action.user];

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
