import * as round from "../../games/game/round";

/**
 * Indicates that the stage timer has completed.
 */
export interface StageTimerDone {
  event: "StageTimerDone";
  round: string;
  stage: round.Stage;
}

export const of = (roundId: round.Id, stage: round.Stage): StageTimerDone => ({
  event: "StageTimerDone",
  round: roundId.toString(),
  stage
});
