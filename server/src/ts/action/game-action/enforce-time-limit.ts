import { Action } from "../../action";
import * as gameAction from "../game-action";

/**
 * A player asks to enforce the soft time limit for the game.
 */
export interface EnforceTimeLimit {
  action: "EnforceTimeLimit";
}

type NameType = "EnforceTimeLimit";
const name: NameType = "EnforceTimeLimit";

export const is = (action: Action): action is EnforceTimeLimit =>
  action.action === name;

export const handle: gameAction.Handler<EnforceTimeLimit> = (
  auth,
  lobby,
  action
) => ({});
