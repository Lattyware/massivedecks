import * as Card from "../../games/cards/card";
import { Hand } from "../../games/cards/hand";
import * as Lobby from "../../lobby";

/**
 * Synchronise the game state.
 */
export interface Sync {
  event: "Sync";
  state: Lobby.Public;
  hand?: Hand;
  play?: Card.Id[];
  gameTime: number;
}

export const of = (
  state: Lobby.Public,
  hand?: Hand,
  play?: Card.Id[]
): Sync => ({
  event: "Sync",
  state,
  ...(hand !== undefined ? { hand } : {}),
  ...(play !== undefined ? { play } : {}),
  gameTime: Date.now(),
});
