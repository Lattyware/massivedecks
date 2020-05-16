import * as Timeout from "../timeout";
import * as Rules from "../games/rules";

/**
 * Indicates that the round should start the judging phase if it is appropriate
 * to do so.
 */
export interface FinishedRevealing {
  timeout: "FinishedRevealing";
}

export const of = (stages: Rules.Stages): Timeout.After => ({
  timeout: {
    timeout: "FinishedRevealing",
  },
  after: (stages.revealing === undefined ? 0 : stages.revealing.after) * 1000,
});

export const handle: Timeout.Handler<FinishedRevealing> = (
  server,
  timeout,
  gameCode,
  lobby
) => {
  const game = lobby.game;
  if (game === undefined) {
    return {};
  }
  const round = game.round;
  if (round.stage !== "Revealing") {
    return {};
  }
  const advanced = round.advance(game, true);
  if (advanced === undefined) {
    return {};
  }
  game.round = advanced.round;
  return {
    lobby,
    events: advanced.events,
    timeouts: advanced.timeouts,
  };
};
