import * as user from "../../user";

/**
 * An event for when connection state for a user changes.
 */
export type ConnectionChanged = Connected | Disconnected;

interface Base {
  user: user.Id;
}

/**
 * A user connects to the lobby.
 */
export interface Connected extends Base {
  event: "Connected";
}

export const connected = (user: user.Id): Connected => ({
  event: "Connected",
  user
});

/**
 * A user disconnects from the lobby.
 */
export interface Disconnected extends Base {
  event: "Disconnected";
}

export const disconnected = (user: user.Id): Disconnected => ({
  event: "Disconnected",
  user
});
