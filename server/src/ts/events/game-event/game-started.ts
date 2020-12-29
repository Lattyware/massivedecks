import * as Card from "../../games/cards/card";
import * as Round from "../../games/game/round";
import * as PublicRound from "../../games/game/round/public";

/**
 * Indicated a game has started in the lobby.
 */
export interface Base {
  event: "GameStarted";
  round: PublicRound.Starting | PublicRound.Playing;
  hand?: Card.Response[];
}

export interface Starting {
  round: PublicRound.Starting;
  calls?: Card.Call[];
}

export interface Playing {
  round: PublicRound.Playing;
}

export type GameStarted = Base & (Starting | Playing);

export const ofPlaying = (
  startedRound: Round.Playing
): GameStarted & Playing => ({
  event: "GameStarted",
  round: startedRound.public(),
});

export const ofStarting = (
  startedRound: Round.Starting
): GameStarted & Starting => ({
  event: "GameStarted",
  round: startedRound.public(),
});
