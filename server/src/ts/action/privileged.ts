import wu from "wu";
import { Action } from "../action";
import { UnprivilegedError } from "../errors/action-execution-error";
import * as util from "../util";
import { Handler } from "./handler";
import { Configure } from "./privileged/configure";
import * as configure from "./privileged/configure";
import * as startGame from "./privileged/start-game";
import { StartGame } from "./privileged/start-game";

/**
 * An action only a privileged user can perform.
 */
export type Privileged = Configure | StartGame;

const possible = new Set([configure.is, startGame.is]);

/**
 * Check if an action is a configure action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Privileged =>
  wu(possible).some(is => is(action));

export const handle: Handler<Privileged> = (auth, lobby, action, server) => {
  if (auth.pvg !== "Privileged") {
    throw new UnprivilegedError(action);
  }
  if (configure.is(action)) {
    return configure.handle(auth, lobby, action, server);
  } else if (startGame.is(action)) {
    return startGame.handle(auth, lobby, action, server);
  } else {
    return util.assertNever(action);
  }
};
