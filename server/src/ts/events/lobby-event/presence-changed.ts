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

export const joined = (user: user.Id, name: user.Name): Joined => ({
  event: "Joined",
  user,
  name
});

/**
 * A user disconnects from the lobby.
 */
export interface Left extends Base {
  event: "Left";
}

export const left = (user: user.Id): Left => ({
  event: "Left",
  user
});
