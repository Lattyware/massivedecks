import { Action } from "../../action";
import * as util from "../../util";
import * as gameAction from "../game-action";
import * as judge from "./czar/judge";
import { Judge } from "./czar/judge";
import * as reveal from "./czar/reveal";
import { Reveal } from "./czar/reveal";
import wu = require("wu");

/**
 * An action only the czar can perform.
 */
export type Czar = Judge | Reveal;

const possible = new Set([judge.is, reveal.is]);

/**
 * Check if an action is a player action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Czar =>
  wu(possible).some(is => is(action));

export const handle: gameAction.Handler<Czar> = (
  auth,
  lobby,
  action,
  server
) => {
  gameAction.expectRole(auth, action, lobby.game, "Czar");
  if (judge.is(action)) {
    return judge.handle(auth, lobby, action, server);
  } else if (reveal.is(action)) {
    return reveal.handle(auth, lobby, action, server);
  } else {
    return util.assertNever(action);
  }
};
