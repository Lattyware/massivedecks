import type { Action } from "../action.js";
import type { Lobby } from "../lobby.js";
import type { Change } from "../lobby/change.js";
import type { ServerState } from "../server-state.js";
import type * as Token from "../user/token.js";

/**
 * A handler for a given type of action where the lobby is customised.
 * This can let us avoid making the same checks down the line.
 */
export type Custom<A extends Action, L extends Lobby> = (
  auth: Token.Claims,
  lobby: L,
  action: A,
  server: ServerState,
) => Change;

/**
 * A handler for a given type of action.
 */
export type Handler<A extends Action> = Custom<A, Lobby>;
