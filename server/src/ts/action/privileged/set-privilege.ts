import { Action } from "../../action";
import { InvalidActionError } from "../../errors/validation";
import * as event from "../../event";
import * as privilegeChanged from "../../events/lobby-event/privilege-changed";
import * as user from "../../user";
import { User } from "../../user";
import { Handler } from "../handler";

/**
 * A privileged user asks to change the privilege of another user.
 */
export interface SetPrivilege {
  action: NameType;
  user: user.Id;
  privilege: user.Privilege;
}

type NameType = "SetPrivilege";
const name: NameType = "SetPrivilege";

export const is = (action: Action): action is SetPrivilege =>
  action.action === name;

export const handle: Handler<SetPrivilege> = (auth, lobby, action) => {
  const user = lobby.users.get(action.user) as User;

  if (user.control === "Computer") {
    throw new InvalidActionError("Can't do this with AIs.");
  }

  const privilege = action.privilege;

  if (user.privilege !== privilege) {
    user.privilege = privilege;
    return {
      lobby,
      events: [event.targetAll(privilegeChanged.of(action.user, privilege))]
    };
  }
  return {};
};
