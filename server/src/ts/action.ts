import * as Actions from "./action/actions";
import * as Authenticate from "./action/authenticate";
import * as GameAction from "./action/game-action";
import * as Handler from "./action/handler";
import * as Leave from "./action/leave";
import * as Privileged from "./action/privileged";
import * as SetUserRole from "./action/set-user-role";
import * as Validation from "./action/validation.validator";
import { AlreadyAuthenticatedError } from "./errors/authentication";
import { InvalidActionError } from "./errors/validation";

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
  Leave.actions
);

const _validateAction = Validation.validate("Action");
export const validate = (action: object): Action => {
  try {
    return _validateAction(action);
  } catch (e) {
    throw new InvalidActionError(e.message);
  }
};

export const handle: Handler.Handler<Action> = (
  auth,
  lobby,
  action,
  config
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
