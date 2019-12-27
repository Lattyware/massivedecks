import * as round from "../games/game/round";
import { Round } from "../games/game/round";
import { Config } from "../lobby/config";
import * as timeout from "../timeout";

/**
 * Indicates that the user should be marked as disconnected if they still are.
 */
export interface RoundStageTimerDone {
  timeout: "RoundStageTimerDone";
  round: round.Id;
  stage: round.Stage;
}

export const of = (round: Round): RoundStageTimerDone => ({
  timeout: "RoundStageTimerDone",
  round: round.id,
  stage: round.stage
});

export const ifEnabled = (
  round: Round,
  config: Config
): RoundStageTimerDone | null =>
  config.rules.timeLimits !== undefined ? of(round) : null;

export const handle: timeout.Handler<RoundStageTimerDone> = (
  server,
  timeout,
  gameCode,
  lobby
) => {
  const timeLimits = lobby.config.rules.timeLimits;
  const game = lobby.game;
  if (timeLimits === undefined || game === undefined) {
    return {};
  }
  const gameRound = game.round;
  if (gameRound.id !== timeout.round || gameRound.stage !== timeout.stage) {
    return {};
  }
  const waitingFor = gameRound.waitingFor();
  if (waitingFor === null) {
    return {};
  }
  switch (timeLimits.mode) {
    case "Soft":
      break;
    case "Hard":
      break;
  }
  return {};
};
