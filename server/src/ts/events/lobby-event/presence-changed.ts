import * as User from "../../user";

/**
 * An event for when connection state for a user changes.
 */
export type PresenceChanged = Joined | Left;

interface Base {
  user: User.Id;
}

/**
 * A user connects to the lobby.
 */
export interface Joined extends Base {
  event: "Joined";
  name: User.Name;
  privilege?: User.Privilege;
  control?: User.Control;
}

export const joined = (id: User.Id, user: User.User): Joined => ({
  event: "Joined",
  user: id,
  name: user.name,
  ...(user.privilege !== "Unprivileged" ? { privilege: user.privilege } : {}),
  ...(user.control !== "Human" ? { control: user.control } : {}),
});

export type LeaveReason = "Left" | "Kicked";

/**
 * A user disconnects from the lobby.
 */
export interface Left extends Base {
  event: "Left";
  reason?: LeaveReason;
}

export const left = (user: User.Id, reason: LeaveReason): Left => ({
  event: "Left",
  user,
  ...(reason !== "Left" ? { reason } : {}),
});
