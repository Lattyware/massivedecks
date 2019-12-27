import wu from "wu";
import { Action } from "../../action";
import * as util from "../../util";
import * as gameAction from "../game-action";
import * as submit from "./player/submit";
import { Submit } from "./player/submit";
import * as takeBack from "./player/take-back";
import { TakeBack } from "./player/take-back";

/**
 * An action only the czar can perform.
 */
export type Player = Submit | TakeBack;

const possible = new Set([submit.is, takeBack.is]);

/**
 * Check if an action is a non-czar action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Player =>
  wu(possible).some(is => is(action));

export const handle: gameAction.Handler<Player> = (
  auth,
  lobby,
  action,
  server
) => {
  gameAction.expectRole(auth, action, lobby.game, "Player");
  if (submit.is(action)) {
    return submit.handle(auth, lobby, action, server);
  } else if (takeBack.is(action)) {
    return takeBack.handle(auth, lobby, action, server);
  } else {
    return util.assertNever(action);
  }
};
