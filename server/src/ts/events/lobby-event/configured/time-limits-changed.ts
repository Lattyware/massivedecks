import * as round from "../../../games/game/round";
import { TimeLimit, TimeLimitMode } from "../../../games/rules";
import * as configured from "../configured";

/**
 * The time limits for the lobby have changed.
 */
export type TimeLimitsChanged = TimeLimitForStageChanged | TimeLimitModeChanged;

interface Base extends configured.Base {
  event: "TimeLimitsChanged";
}

/**
 * The time limit for a given stage are changed.
 */
export interface TimeLimitForStageChanged extends Base {
  stage: round.Stage;
  timeLimit: TimeLimit;
}

export const forStage = (
  version: string,
  stage: round.Stage,
  timeLimit: TimeLimit
): TimeLimitForStageChanged => ({
  event: "TimeLimitsChanged",
  version,
  stage,
  timeLimit
});

/**
 * The time limit mode if changed.
 */
export interface TimeLimitModeChanged extends Base {
  mode: TimeLimitMode | null;
}

export const mode = (
  version: string,
  mode: TimeLimitMode | null
): TimeLimitModeChanged => ({
  event: "TimeLimitsChanged",
  version,
  mode
});
