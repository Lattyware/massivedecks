import { dealWithLostPlayer } from "../action/game-action/set-presence";
import * as Event from "../event";
import * as StageTimerDone from "../events/game-event/stage-timer-done";
import * as Round from "../games/game/round";
import * as Rules from "../games/rules";
import * as Lobby from "../lobby";
import * as Change from "../lobby/change";
import * as Timeout from "../timeout";
import * as Util from "../util";
import { Stages } from "../games/rules";

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
 * @param stages The time limits in use.
 */
function stageDuration(stage: Round.Stage, stages: Stages): number | undefined {
  switch (stage) {
    case "Playing":
      return stages.playing.after;
    case "Revealing":
      return stages.revealing === undefined
        ? undefined
        : stages.revealing.duration;
    case "Judging":
      return stages.judging.after;
    case "Complete":
      return undefined;
    default:
      Util.assertNever(stage);
  }
}

/**
 * Give a round stage timer if one is enabled.
 * @param round the active round.
 * @param stages the active time limits.
 */
export const ifEnabled = (
  round: Round.Round,
  stages: Rules.Stages
): Timeout.After | undefined => {
  const afterSeconds = stageDuration(round.stage, stages);
  if (afterSeconds === undefined) {
    return undefined;
  }
  return {
    timeout: {
      timeout: "RoundStageTimerDone",
      round: round.id,
      stage: round.stage,
    },
    after: afterSeconds * 1000,
  };
};

export const handle: Timeout.Handler<RoundStageTimerDone> = (
  server,
  timeout,
  gameCode,
  lobby
) => {
  const game = lobby.game;
  if (game === undefined) {
    return {};
  }
  const stages = game.rules.stages;
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
  switch (stages.timeLimitMode) {
    case "Soft":
      return {
        events: [
          Event.targetAll(StageTimerDone.of(timeout.round, timeout.stage)),
        ],
      };
    case "Hard":
      return Change.reduce(waitingFor, lobby as Lobby.WithActiveGame, (l, p) =>
        dealWithLostPlayer(server, l, p)
      );
    default:
      Util.assertNever(stages.timeLimitMode);
  }
  return {};
};
