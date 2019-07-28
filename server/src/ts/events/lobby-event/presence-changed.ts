import { User } from "../../user";
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
  privilege?: user.Privilege;
  control?: user.Control;
}

export const joined = (id: user.Id, user: User): Joined => ({
  event: "Joined",
  user: id,
  name: user.name,
  ...(user.privilege !== "Unprivileged" ? { privilege: user.privilege } : {}),
  ...(user.control !== "Human" ? { control: user.control } : {})
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
