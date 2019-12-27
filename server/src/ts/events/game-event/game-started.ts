import * as card from "../../games/cards/card";
import * as round from "../../games/game/round";
import * as publicRound from "../../games/game/round/public";

/**
 * Indicated a game has started in the lobby.
 */
export interface GameStarted {
  event: "GameStarted";
  round: publicRound.Playing;
  hand?: card.Response[];
}

export const of = (
  startedRound: round.Playing,
  hand?: card.Response[]
): GameStarted => ({
  event: "GameStarted",
  round: startedRound.public(),
  ...(hand !== undefined ? { hand } : {})
});
