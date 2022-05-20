import wu from "wu";

import type * as Round from "../games/game/round.js";
import type * as Rules from "../games/rules.js";
import type * as Timeout from "../timeout.js";
import * as Util from "../util.js";

/**
 * Indicates that the round should start the revealing phase if it is appropriate
 * to do so.
 */
export interface FinishedPlaying {
  timeout: "FinishedPlaying";
}

const isFinished = (round: Round.Playing): boolean => {
  const hasPlayed = new Set(wu(round.plays).map((play) => play.playedBy));
  return Util.setEquals(round.players, hasPlayed);
};

export const ifNeeded = (
  rules: Rules.Rules,
  playing: Round.Playing,
): Timeout.After | undefined =>
  isFinished(playing)
    ? {
        timeout: {
          timeout: "FinishedPlaying",
        },
        after: rules.stages.playing.after * 1000,
      }
    : undefined;

export const handle: Timeout.Handler<FinishedPlaying> = (
  server,
  timeout,
  gameCode,
  lobby,
) => {
  const game = lobby.game;
  if (game === undefined) {
    return {};
  }
  if (game.round.stage !== "Playing" || !isFinished(game.round)) {
    return {};
  }

  const continuation =
    game.rules.stages.revealing === undefined
      ? game.round.skipToJudging(game)
      : game.round.advance(game);

  if (continuation !== undefined) {
    const { round, events, timeouts } = continuation;
    game.round = round;
    return {
      lobby,
      events,
      timeouts,
    };
  } else {
    // There were no plays, presumably everyone got skipped or something.
    // We should start a new round because the czar has nothing to pick from.
    const { events, timeouts } = game.startNewRound(server, lobby);
    return {
      lobby,
      events,
      timeouts,
    };
  }
};
