import * as Card from "../../games/cards/card";
import { Hand } from "../../games/cards/hand";
import * as Lobby from "../../lobby";
import { LikeDetail } from "../../games/game/round/public";

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
  calls?: Card.Call[]
): Sync => ({
  event: "Sync",
  state,
  ...(hand !== undefined ? { hand } : {}),
  ...(play !== undefined ? { play } : {}),
  ...(likeDetail !== undefined ? { likeDetail } : {}),
  ...(calls !== undefined ? { calls } : {}),
  gameTime: Date.now(),
});
