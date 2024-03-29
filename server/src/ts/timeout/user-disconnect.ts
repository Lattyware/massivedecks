import wu from "wu";

import * as Event from "../event.js";
import * as ConnectionChanged from "../events/lobby-event/connection-changed.js";
import type * as Timeout from "../timeout.js";
import type * as User from "../user.js";

/**
 * Indicates that the user should be marked as disconnected if they still are.
 */
export interface UserDisconnect {
  timeout: "UserDisconnect";
  user: User.Id;
}

export const of = (user: User.Id): UserDisconnect => ({
  timeout: "UserDisconnect",
  user,
});

export const handle: Timeout.Handler<UserDisconnect> = (
  server,
  timeout,
  gameCode,
  lobby,
) => {
  const id = timeout.user;
  const sockets = server.socketManager.sockets.get(gameCode, id);
  if (!wu(sockets).some(() => true)) {
    const userData = lobby.users[id];
    if (userData === undefined) {
      throw new Error("Player not in lobby.");
    }
    if (userData.connection !== "Disconnected") {
      userData.connection = "Disconnected";
      const events =
        userData.presence !== "Left"
          ? [Event.targetAll(ConnectionChanged.disconnected(id))]
          : [];
      return {
        lobby,
        events,
      };
    }
  }
  return {};
};
