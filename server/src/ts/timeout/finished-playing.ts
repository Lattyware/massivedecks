import wu from "wu";
import * as Round from "../games/game/round";
import * as Timeout from "../timeout";
import * as Util from "../util";
import * as Rules from "../games/rules";

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
  playing: Round.Playing
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
  lobby
) => {
  const game = lobby.game;
  if (game === undefined) {
    return {};
  }
  if (game.round.stage !== "Playing" || !isFinished(game.round)) {
    return {};
  }

  // We discard the plays first so if the deck runs out, all the cards get
  // rotated in.
  for (const play of game.round.plays) {
    game.decks.responses.discard(play.play);
  }

  const { round, events, timeouts } =
    game.rules.stages.revealing === undefined
      ? game.round.skipToJudging(game)
      : game.round.advance(game);
  game.round = round;
  return {
    lobby,
    events,
    timeouts,
  };
};
