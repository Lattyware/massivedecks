import type * as Action from "../action.js";
import * as ActionExecutionError from "../errors/action-execution-error.js";
import { GameNotStartedError } from "../errors/action-execution-error.js";
import type { Game } from "../games/game.js";
import * as Player from "../games/player.js";
import * as Lobby from "../lobby.js";
import type { ServerState } from "../server-state.js";
import type * as Token from "../user/token.js";
import * as Actions from "./actions.js";
import * as Czar from "./game-action/czar.js";
import * as EnforceTimeLimit from "./game-action/enforce-time-limit.js";
import * as Like from "./game-action/like.js";
import * as PlayerAction from "./game-action/player.js";
import * as Redraw from "./game-action/redraw.js";
import * as SetPresence from "./game-action/set-presence.js";

/**
 * An action only a player can perform.
 */
export type GameAction =
  | PlayerAction.Player
  | Czar.Czar
  | Redraw.Redraw
  | EnforceTimeLimit.EnforceTimeLimit
  | SetPresence.SetPresence
  | Like.Like;

class GameActions extends Actions.Group<
  Action.Action,
  GameAction,
  Lobby.Lobby,
  Lobby.WithActiveGame
> {
  constructor() {
    super(
      PlayerAction.actions,
      Czar.actions,
      Redraw.actions,
      EnforceTimeLimit.actions,
      SetPresence.actions,
      Like.actions,
    );
  }

  public limit(
    _auth: Token.Claims,
    lobby: Lobby.Lobby,
    action: GameAction,
    _server: ServerState,
  ): lobby is Lobby.WithActiveGame {
    if (!Lobby.hasActiveGame(lobby)) {
      throw new GameNotStartedError(action);
    }
    return true;
  }
}

export const actions = new GameActions();

export function expectRole(
  auth: Token.Claims,
  action: Czar.Czar,
  game: Game,
  expected: "Czar",
): void;
export function expectRole(
  auth: Token.Claims,
  action: PlayerAction.Player,
  game: Game,
  expected: "Player",
): void;
/**
 * Expect a given role.
 * @param auth The claims for the user attempting to perform the action.
 * @param action The action being performed.
 * @param game The game being played.
 * @param expected The expected role for the user.
 */
export function expectRole(
  auth: Token.Claims,
  action: GameAction,
  game: Game,
  expected: Player.Role,
): void {
  const playerRole = Player.role(auth.uid, game);
  if (playerRole !== expected) {
    throw new ActionExecutionError.IncorrectPlayerRoleError(
      action,
      playerRole,
      expected,
    );
  }
}
