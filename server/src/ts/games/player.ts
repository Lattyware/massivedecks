import * as User from "../user";
import { Hand } from "./cards/hand";
import { Game } from "./game";

/**
 * A player containing only state all users can see.
 */
export interface Public {
  score: Score;
  likes: Likes;
  presence: Presence;
}

/**
 * The role the player currently has in the game.
 */
export type Role = "Czar" | "Player";

/**
 * How many points the player has scored.
 * @TJS-type integer
 * @minimum 0
 */
export type Score = number;

/**
 * How many likes the player has received.
 * @TJS-type integer
 * @minimum 0
 */
export type Likes = number;

/**
 * If the player is active in the game or has been marked as away.
 */
export type Presence = "Active" | "Away";

/**
 * A player in the game.
 */
export interface Player {
  hand: Hand;
  score: Score;
  presence: Presence;
  likes: Likes;
}

export const initial = (hand: Hand): Player => ({
  hand: hand,
  score: 0,
  likes: 0,
  presence: "Active",
});

export const censor = (player: Player): Public => ({
  score: player.score,
  presence: player.presence,
  likes: player.likes,
});

/**
 * Get the given player's role in the current round, or null if they are not
 * in the round.
 * @param id The player's id.
 * @param game The game.
 */
export function role(id: User.Id, game: Game): Role | null {
  if (game.round.czar === id) {
    return "Czar";
  } else if (game.round.players.has(id)) {
    return "Player";
  } else {
    return null;
  }
}
