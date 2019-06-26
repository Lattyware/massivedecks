import { InvalidAuthenticationError } from "../errors/authentication";
import * as event from "../event";
import { ServerState } from "../server-state";
import { GameCode } from "../lobby/game-code";
import { User } from "../user";
import * as token from "../user/token";
import { Token } from "../user/token";
import { Action } from "../action";
import * as change from "../lobby/change";
import * as connectionChanged from "../events/lobby-event/connection-changed";

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
    const user = lobby.users.get(claims.uid) as User;
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
