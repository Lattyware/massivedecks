import * as Card from "../../games/cards/card";
import * as Round from "../../games/game/round";
import * as PublicRound from "../../games/game/round/public";

/**
 * Indicated a game has started in the lobby.
 */
export interface GameStarted {
  event: "GameStarted";
  round: PublicRound.Playing;
  hand?: Card.Response[];
}

export const of = (
  startedRound: Round.Playing,
  hand?: Card.Response[]
): GameStarted => ({
  event: "GameStarted",
  round: startedRound.public(),
  ...(hand !== undefined ? { hand } : {}),
});
