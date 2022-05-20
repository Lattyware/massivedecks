import type * as Card from "../../games/cards/card.js";
import type { Hand } from "../../games/cards/hand.js";
import type { LikeDetail } from "../../games/game/round/public.js";
import type * as Lobby from "../../lobby.js";

/**
 * Synchronise the game state.
 */
export interface Sync {
  event: "Sync";
  state: Lobby.Public;
  hand?: Hand;
  calls?: Card.Call[];
  play?: Card.Id[];
  likeDetail?: LikeDetail;
  gameTime: number;
}

export const of = (
  state: Lobby.Public,
  hand?: Hand,
  play?: Card.Id[],
  likeDetail?: LikeDetail,
  calls?: Card.Call[],
): Sync => ({
  event: "Sync",
  state,
  ...(hand !== undefined ? { hand } : {}),
  ...(play !== undefined ? { play } : {}),
  ...(likeDetail !== undefined ? { likeDetail } : {}),
  ...(calls !== undefined ? { calls } : {}),
  gameTime: Date.now(),
});
