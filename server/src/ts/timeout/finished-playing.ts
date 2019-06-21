import * as event from "../event";
import * as startRevealing from "../events/game-event/start-revealing";
import * as timeout from "../timeout";
import * as util from "../util";
import * as round from "../games/game/round";
import wu from "wu";

/**
 * Indicates that the round should start the judging phase if it is appropriate
 * to do so.
 */
export interface FinishedPlaying {
  timeout: "FinishedPlaying";
}

const isFinished = (round: round.Playing): boolean => {
  const hasPlayed = new Set(wu(round.plays).map(play => play.playedBy));
  return util.setEquals(round.players, hasPlayed);
};

export const of = (): FinishedPlaying => ({
  timeout: "FinishedPlaying"
});

export const ifNeeded = (playing: round.Playing): FinishedPlaying | undefined =>
  isFinished(playing) ? of() : undefined;

export const handle: timeout.Handler<FinishedPlaying> = (
  server,
  timeout,
  lobby
) => {
  const game = lobby.game;
  if (game === undefined) {
    return {};
  }
  const round = game.round;
  const plays = round.plays;
  if (round.stage !== "Playing" || !isFinished(round)) {
    return {};
  }
  game.round = {
    ...round,
    stage: "Revealing"
  };
  const ids = Array.from(wu(plays).map(play => play.id));
  return {
    lobby,
    events: [event.target(startRevealing.of(ids))]
  };
};
