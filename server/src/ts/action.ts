import * as Actions from "./action/actions.js";
import * as Authenticate from "./action/authenticate.js";
import * as GameAction from "./action/game-action.js";
import type * as Handler from "./action/handler.js";
import * as Leave from "./action/leave.js";
import * as Privileged from "./action/privileged.js";
import * as SetUserRole from "./action/set-user-role.js";
import * as Validation from "./action/validation.validator.js";
import { AlreadyAuthenticatedError } from "./errors/authentication.js";
import { InvalidActionError } from "./errors/validation.js";

/**
 * An action a user takes to affect the game in some way, received via a
 * websocket (therefore with no hints as to what the action will be).
 */
export type Action =
  | Authenticate.Authenticate
  | GameAction.GameAction
  | Privileged.Privileged
  | SetUserRole.SetUserRole
  | Leave.Leave;

const allActions = new Actions.PassThroughGroup(
  GameAction.actions,
  Privileged.actions,
  SetUserRole.actions,
  Leave.actions,
);

const _validateAction = Validation.validate("Action");
export const validate = (action: object): Action => {
  try {
    return _validateAction(action);
  } catch (e) {
    const error = e as Error;
    throw new InvalidActionError(error.message);
  }
};

export const handle: Handler.Handler<Action> = (
  auth,
  lobby,
  action,
  config,
) => {
  const validated = validate(action);
  if (Authenticate.is(validated)) {
    throw new AlreadyAuthenticatedError();
  } else {
    const change = allActions.tryHandle(auth, lobby, validated, config);
    if (change !== undefined) {
      return change;
    } else {
      throw Error(`Unhandled action type: ${action}.`);
    }
  }
};
