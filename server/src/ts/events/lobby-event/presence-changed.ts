import * as user from "../../user";

/**
 * An event for when connection state for a user changes.
 */
export type PresenceChanged = Joined | Left;

interface Base {
  user: user.Id;
}

/**
 * A user connects to the lobby.
 */
export interface Joined extends Base {
  event: "Joined";
  name: user.Name;
}

/**
 * A user disconnects from the lobby.
 */
export interface Left extends Base {
  event: "Left";
}
