import { dealWithLostPlayer } from "../action/game-action/set-presence";
import * as round from "../games/game/round";
import { Round } from "../games/game/round";
import { RoundTimeLimits } from "../games/rules";
import * as Lobby from "../lobby";
import * as change from "../lobby/change";
import { TimeoutAfter } from "../timeout";
import * as timeout from "../timeout";
import { assertNever } from "../util";
import * as stageTimerDone from "../events/game-event/stage-timer-done";
import * as event from "../event";
import * as util from "../util";

/**
 * Indicates that the user should be marked as disconnected if they still are.
 */
export interface RoundStageTimerDone {
  timeout: "RoundStageTimerDone";
  round: round.Id;
  stage: round.Stage;
}

/**
 * Note that the config has seconds, not milliseconds.
 * @param stage The stage you are in.
 * @param timeLimits The time limits in use.
 */
function timeFromConfig(
  stage: round.Stage,
  timeLimits: RoundTimeLimits
): number | undefined {
  switch (stage) {
    case "Playing":
      return timeLimits.playing;
    case "Revealing":
      return timeLimits.revealing;
    case "Judging":
      return timeLimits.judging;
    case "Complete":
      return undefined;
    default:
      assertNever(stage);
  }
}

/**
 * Give a round stage timer if one is enabled.
 * @param round the active round.
 * @param timeLimits the active time limits.
 */
export const ifEnabled = (
  round: Round,
  timeLimits: RoundTimeLimits | undefined
): TimeoutAfter | undefined => {
  if (timeLimits === undefined) {
    return undefined;
  }
  const afterSeconds = timeFromConfig(round.stage, timeLimits);
  if (afterSeconds === undefined) {
    return undefined;
  }
  return {
    timeout: {
      timeout: "RoundStageTimerDone",
      round: round.id,
      stage: round.stage
    },
    after: afterSeconds * 1000
  };
};

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
  if (
    gameRound.id !== timeout.round ||
    gameRound.stage !== timeout.stage ||
    !round.isTimed(gameRound) ||
    gameRound.timedOut
  ) {
    return {};
  }
  const waitingFor = gameRound.waitingFor();
  if (waitingFor === null) {
    return {};
  }
  gameRound.timedOut = true;
  switch (timeLimits.mode) {
    case "Soft":
      return {
        events: [
          event.targetAll(stageTimerDone.of(timeout.round, timeout.stage))
        ]
      };
    case "Hard":
      return change.reduce(waitingFor, lobby as Lobby.WithActiveGame, (l, p) =>
        dealWithLostPlayer(server, l, p)
      );
    default:
      util.assertNever(timeLimits.mode);
  }
  return {};
};
