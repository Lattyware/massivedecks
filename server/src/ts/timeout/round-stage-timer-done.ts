import { dealWithLostPlayer } from "../action/game-action/set-presence";
import * as Event from "../event";
import * as StageTimerDone from "../events/game-event/stage-timer-done";
import * as Round from "../games/game/round";
import { RoundTimeLimits } from "../games/rules";
import * as Lobby from "../lobby";
import * as Change from "../lobby/change";
import * as Timeout from "../timeout";
import * as Util from "../util";

/**
 * Indicates that the user should be marked as disconnected if they still are.
 */
export interface RoundStageTimerDone {
  timeout: "RoundStageTimerDone";
  round: Round.Id;
  stage: Round.Stage;
}

/**
 * Note that the config has seconds, not milliseconds.
 * @param stage The stage you are in.
 * @param timeLimits The time limits in use.
 */
function timeFromConfig(
  stage: Round.Stage,
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
      Util.assertNever(stage);
  }
}

/**
 * Give a round stage timer if one is enabled.
 * @param round the active round.
 * @param timeLimits the active time limits.
 */
export const ifEnabled = (
  round: Round.Round,
  timeLimits: RoundTimeLimits | undefined
): Timeout.After | undefined => {
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

export const handle: Timeout.Handler<RoundStageTimerDone> = (
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
    !Round.isTimed(gameRound) ||
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
          Event.targetAll(StageTimerDone.of(timeout.round, timeout.stage))
        ]
      };
    case "Hard":
      return Change.reduce(waitingFor, lobby as Lobby.WithActiveGame, (l, p) =>
        dealWithLostPlayer(server, l, p)
      );
    default:
      Util.assertNever(timeLimits.mode);
  }
  return {};
};
