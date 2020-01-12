import { Action } from "../action";
import {
  AlreadyLeftError,
  InvalidAuthenticationError
} from "../errors/authentication";
import * as event from "../event";
import * as connectionChanged from "../events/lobby-event/connection-changed";
import * as change from "../lobby/change";
import { GameCode } from "../lobby/game-code";
import { ServerState } from "../server-state";
import * as token from "../user/token";
import { Token } from "../user/token";

/**
 * Authenticate with the game.
 */
export interface Authenticate {
  action: NameType;
  token: Token;
}

type NameType = "Authenticate";
const name: NameType = "Authenticate";

/**
 * Check if an action is an authenticate action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Authenticate =>
  action.action === name;

/**
 * Handle the authentication, returning the validated claim if successful.
 * @param server The server state.
 * @param authenticate The action.
 * @param gameCode The game code for the lobby to validate in.
 */
export async function handle(
  server: ServerState,
  authenticate: Authenticate,
  gameCode: GameCode
): Promise<token.Claims> {
  const claims = token.validate(
    authenticate.token,
    await server.store.id(),
    server.config.secret
  );
  if (claims.gc !== gameCode) {
    throw new InvalidAuthenticationError("wrong game code");
  }
  await change.apply(server, gameCode, lobby => {
    const user = lobby.users.get(claims.uid);
    if (user === undefined) {
      throw new InvalidAuthenticationError("no such user");
    }
    if (user.presence === "Left") {
      throw new AlreadyLeftError();
    }
    if (user.connection !== "Connected") {
      user.connection = "Connected";
      return {
        events: [event.targetAll(connectionChanged.connected(claims.uid))]
      };
    } else {
      return {};
    }
  });
  return claims;
}
