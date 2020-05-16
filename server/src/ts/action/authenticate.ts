import { Action } from "../action";
import * as Authentication from "../errors/authentication";
import * as Event from "../event";
import * as ConnectionChanged from "../events/lobby-event/connection-changed";
import * as Change from "../lobby/change";
import { GameCode } from "../lobby/game-code";
import { ServerState } from "../server-state";
import * as Token from "../user/token";

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
  gameCode: GameCode
): Promise<Token.Claims> {
  const claims = Token.validate(
    authenticate.token,
    await server.store.id(),
    server.config.secret
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
