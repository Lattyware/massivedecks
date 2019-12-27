import * as event from "../event";
import * as connectionChanged from "../events/lobby-event/connection-changed";
import * as timeout from "../timeout";
import * as user from "../user";

/**
 * Indicates that the user should be marked as disconnected if they still are.
 */
export interface UserDisconnect {
  timeout: "UserDisconnect";
  user: user.Id;
}

export const of = (user: user.Id): UserDisconnect => ({
  timeout: "UserDisconnect",
  user
});

export const handle: timeout.Handler<UserDisconnect> = (
  server,
  timeout,
  gameCode,
  lobby
) => {
  const id = timeout.user;
  const socket = server.socketManager.sockets.get(gameCode, id);
  if (socket === undefined) {
    const userData = lobby.users.get(id);
    if (userData === undefined) {
      throw new Error("Player not in lobby.");
    }
    if (userData.connection !== "Disconnected") {
      userData.connection = "Disconnected";
      return {
        lobby,
        events: [event.targetAll(connectionChanged.disconnected(id))]
      };
    }
  }
  return {};
};
