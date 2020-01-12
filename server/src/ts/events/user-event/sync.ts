import * as card from "../../games/cards/card";
import { Hand } from "../../games/cards/hand";
import * as lobby from "../../lobby";

/**
 * Synchronise the game state.
 */
export interface Sync {
  event: "Sync";
  state: lobby.Public;
  hand?: Hand;
  play?: card.Id[];
  gameTime: number;
}

export const of = (
  state: lobby.Public,
  hand?: Hand,
  play?: card.Id[]
): Sync => ({
  event: "Sync",
  state,
  ...(hand !== undefined ? { hand } : {}),
  ...(play !== undefined ? { play } : {}),
  gameTime: Date.now()
});
