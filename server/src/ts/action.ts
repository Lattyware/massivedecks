import * as authenticate from "./action/authenticate";
import { Authenticate } from "./action/authenticate";
import * as gameAction from "./action/game-action";
import { GameAction } from "./action/game-action";
import { Handler } from "./action/handler";
import * as leave from "./action/leave";
import { Leave } from "./action/leave";
import * as privileged from "./action/privileged";
import { Privileged } from "./action/privileged";
import * as validation from "./action/validation.validator";
import { AlreadyAuthenticatedError } from "./errors/authentication";
import { InvalidActionError } from "./errors/validation";
import * as util from "./util";

/**
 * An action a user takes to affect the game in some way, received via a
 * websocket (therefore with no hints as to what the action will be).
 */
export type Action = Authenticate | GameAction | Privileged | Leave;

const _validateAction = validation.validate("Action");
export const validate = (action: object): Action => {
  try {
    return _validateAction(action);
  } catch (e) {
    throw new InvalidActionError(e.message);
  }
};

export const handle: Handler<Action> = (auth, lobby, action, config) => {
  const validated = validate(action);
  if (authenticate.is(validated)) {
    throw new AlreadyAuthenticatedError();
  } else if (gameAction.is(validated)) {
    return gameAction.handle(auth, lobby, validated, config);
  } else if (privileged.is(validated)) {
    return privileged.handle(auth, lobby, validated, config);
  } else if (leave.is(validated)) {
    return leave.handle(auth, lobby, validated, config);
  } else {
    return util.assertNever(validated);
  }
};
