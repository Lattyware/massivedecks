import { Action } from "../action";
import { Change } from "../lobby/change";
import { Lobby } from "../lobby";
import * as token from "../user/token";
import { ServerState } from "../server-state";

/**
 * A handler for a given type of action where the lobby is customised.
 * This can let us avoid making the same checks down the line.
 */
export type Custom<A extends Action, L extends Lobby> = (
  auth: token.Claims,
  lobby: L,
  action: A,
  server: ServerState
) => Change;

/**
 * A handler for a given type of action.
 */
export type Handler<A extends Action> = Custom<A, Lobby>;
