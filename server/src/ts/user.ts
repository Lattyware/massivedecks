import { RegisterUser } from "./action/initial/register-user";

/** A user in a lobby.*/
export interface User {
  name: Name;
  presence: Presence;
  connection: Connection;
  privilege: Privilege;
  role: Role;
}

/**
 * A user containing only state all users can see.
 */
export interface Public {
  name: Name;
  presence: Presence;
  connection: Connection;
  privilege: Privilege;
  role: Role;
}

/**
 * A unique id for a user.
 */
export type Id = string;

/**
 * The name the user goes by.
 * @maxLength 100
 * @minLength 1
 */
export type Name = string;

/**
 * The level of privilege a user has.
 */
export type Privilege = "Privileged" | "Unprivileged";

/**
 * If the user is currently in the lobby.
 */
export type Presence = "Joined" | "Left";

/**
 * If the user is connected to the game at this moment.
 */
export type Connection = "Connected" | "Disconnected";

/**
 * If the user is a spectator or a player.
 */
export type Role = "Spectator" | "Player";

/**
 * If the user is playing.
 */
export const isPlaying: (user: User) => boolean = user =>
  user.role === "Player";

/**
 * If the user is spectating.
 */
export const isSpectating: (user: User) => boolean = user =>
  user.role === "Spectator";

/**
 * Create a new user.
 * @param registration The details of the user to create.
 * @param privilege The level of privilege the user has.
 */
export function create(
  registration: RegisterUser,
  privilege: Privilege = "Unprivileged"
): User {
  return {
    name: registration.name,
    presence: "Joined",
    connection: "Connected",
    privilege: privilege,
    role: "Player"
  };
}

/**
 * Gives a version of the user with only publicly visible properties.
 */
export const censor: (user: User) => Public = user => ({
  name: user.name,
  presence: user.presence,
  connection: user.connection,
  privilege: user.privilege,
  role: user.role
});
