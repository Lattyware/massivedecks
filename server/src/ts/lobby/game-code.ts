import Hashids from "hashids";

/**
 * A unique code for a lobby to identify it.
 * @minLength 2
 */
export type GameCode = string;

/**
 * A numeric id for a lobby. This is presented to the user as a game code.
 */
export type LobbyId = number;

// noinspection SpellCheckingInspection
/**
 * Game code methods.
 */
const hashIds = new Hashids(
  "massivedecks",
  2,
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
);

/**
 * Decode a game code to a lobby id.
 */
export const decode = (gameCode: GameCode): LobbyId =>
  Number(hashIds.decode(gameCode)[0]);

/**
 * Decode a lobby id to a game code.
 */
export const encode = (lobbyId: LobbyId): GameCode => hashIds.encode(lobbyId);
