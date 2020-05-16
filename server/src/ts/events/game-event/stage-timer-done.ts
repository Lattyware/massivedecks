import * as Round from "../../games/game/round";

/**
 * Indicates that the stage timer has completed.
 */
export interface StageTimerDone {
  event: "StageTimerDone";
  round: string;
  stage: Round.Stage;
}

export const of = (roundId: Round.Id, stage: Round.Stage): StageTimerDone => ({
  event: "StageTimerDone",
  round: roundId.toString(),
  stage,
});
