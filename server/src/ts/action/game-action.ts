import { Action } from "../action";
import {
  GameNotStartedError,
  IncorrectPlayerRoleError
} from "../errors/action-execution-error";
import { Game } from "../games/game";
import * as player from "../games/player";
import { Player } from "../games/player";
import * as gameLobby from "../lobby";
import * as token from "../user/token";
import * as util from "../util";
import * as czar from "./game-action/czar";
import { Czar } from "./game-action/czar";
import * as enforceTimeLimit from "./game-action/enforce-time-limit";
import { EnforceTimeLimit } from "./game-action/enforce-time-limit";
import * as playerAction from "./game-action/player";
import { Player as PlayerAction } from "./game-action/player";
import * as redraw from "./game-action/redraw";
import { Redraw } from "./game-action/redraw";
import * as setPresence from "./game-action/set-presence";
import { SetPresence } from "./game-action/set-presence";
import * as handler from "./handler";
import wu from "wu";

/**
 * An action only a player can perform.
 */
export type GameAction =
  | PlayerAction
  | Czar
  | Redraw
  | EnforceTimeLimit
  | SetPresence;

/**
 * A handler for game actions.
 */
export type Handler<T extends GameAction> = handler.Custom<
  T,
  gameLobby.WithActiveGame
>;

const possible = new Set([
  playerAction.is,
  czar.is,
  redraw.is,
  enforceTimeLimit.is,
  setPresence.is
]);

/**
 * Check if an action is a configure action.
 * @param action The action to check.
 */
export const is = (action: Action): action is GameAction =>
  wu(possible).some(is => is(action));

export const handle: handler.Handler<GameAction> = (
  auth,
  lobby,
  action,
  server
) => {
  if (gameLobby.hasActiveGame(lobby)) {
    if (czar.is(action)) {
      return czar.handle(auth, lobby, action, server);
    } else if (playerAction.is(action)) {
      return playerAction.handle(auth, lobby, action, server);
    } else if (redraw.is(action)) {
      return redraw.handle(auth, lobby, action, server);
    } else if (enforceTimeLimit.is(action)) {
      return enforceTimeLimit.handle(auth, lobby, action, server);
    } else if (setPresence.is(action)) {
      return setPresence.handle(auth, lobby, action, server);
    } else {
      return util.assertNever(action);
    }
  } else {
    throw new GameNotStartedError(action);
  }
};

export function expectRole(
  auth: token.Claims,
  action: Czar,
  game: Game,
  expected: "Czar"
): void;
export function expectRole(
  auth: token.Claims,
  action: PlayerAction,
  game: Game,
  expected: "Player"
): void;
/**
 * Expect a given role.
 * @param auth The claims for the user attempting to perform the action.
 * @param action The action being performed.
 * @param game The game being played.
 * @param expected The expected role for the user.
 */
export function expectRole(
  auth: token.Claims,
  action: GameAction,
  game: Game,
  expected: player.Role
): void {
  const playerRole = Player.role(auth.uid, game);
  if (playerRole !== expected) {
    throw new IncorrectPlayerRoleError(action, playerRole, expected);
  }
}
