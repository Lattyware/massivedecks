import { RegisterUser } from "./action/initial/register-user";

/** A user in a lobby.*/
export interface User {
  name: Name;
  presence: Presence;
  connection: Connection;
  privilege: Privilege;
  control: Control;
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
  control: Control;
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
 * Who/what is controlling the player—a human or the computer?
 */
export type Control = "Human" | "Computer";

/**
 * If the user is playing.
 */
export const isPlaying: (user: User) => boolean = (user) =>
  user.role === "Player";

/**
 * If the user is spectating.
 */
export const isSpectating: (user: User) => boolean = (user) =>
  user.role === "Spectator";

/**
 * Create a new user.
 * @param registration The details of the user to create.
 * @param role The role the user will have in the game.
 * @param privilege The level of privilege the user has.
 */
export const create = (
  registration: RegisterUser,
  role: Role,
  privilege: Privilege = "Unprivileged"
): User => ({
  name: registration.name,
  presence: "Joined",
  connection: "Connected",
  privilege,
  control: "Human",
  role,
});

/**
 * Gives a version of the user with only publicly visible properties.
 */
export const censor: (user: User) => Public = (user) => ({
  ...user,
});
