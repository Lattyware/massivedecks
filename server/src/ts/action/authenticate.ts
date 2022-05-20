import type { Action } from "../action.js";
import * as Authentication from "../errors/authentication.js";
import * as Event from "../event.js";
import * as ConnectionChanged from "../events/lobby-event/connection-changed.js";
import * as Change from "../lobby/change.js";
import type { GameCode } from "../lobby/game-code.js";
import type { ServerState } from "../server-state.js";
import * as Token from "../user/token.js";

/**
 * Authenticate with the game.
 */
export interface Authenticate {
  action: NameType;
  token: Token.Token;
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
  gameCode: GameCode,
): Promise<Token.Claims> {
  const claims = Token.validate(
    authenticate.token,
    await server.store.id(),
    server.config.secret,
  );
  if (claims.gc !== gameCode) {
    throw new Authentication.InvalidAuthenticationError("wrong game code");
  }
  await Change.apply(server, gameCode, (lobby) => {
    const user = lobby.users[claims.uid];
    if (user === undefined) {
      throw new Authentication.InvalidAuthenticationError("no such user");
    }
    if (user.presence === "Left") {
      throw new Authentication.AlreadyLeftError();
    }
    if (user.connection !== "Connected") {
      user.connection = "Connected";
      return {
        events: [Event.targetAll(ConnectionChanged.connected(claims.uid))],
      };
    } else {
      return {};
    }
  });
  return claims;
}
