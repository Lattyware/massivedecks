import * as User from "../../user";

/**
 * An event for when connection state for a user changes.
 */
export type ConnectionChanged = Connected | Disconnected;

interface Base {
  user: User.Id;
}

/**
 * A user connects to the lobby.
 */
export interface Connected extends Base {
  event: "Connected";
}

export const connected = (user: User.Id): Connected => ({
  event: "Connected",
  user,
});

/**
 * A user disconnects from the lobby.
 */
export interface Disconnected extends Base {
  event: "Disconnected";
}

export const disconnected = (user: User.Id): Disconnected => ({
  event: "Disconnected",
  user,
});
