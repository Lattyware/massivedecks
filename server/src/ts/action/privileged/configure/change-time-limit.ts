import { Action } from "../../../action";
import { InvalidActionError } from "../../../errors/validation";
import * as event from "../../../event";
import * as timeLimitsChanged from "../../../events/lobby-event/configured/time-limits-changed";
import * as round from "../../../games/game/round";
import { TimeLimit, TimeLimitMode } from "../../../games/rules";
import { Handler } from "../../handler";
import * as configure from "../configure";

export type ChangeTimeLimit = ChangeTimeLimitForStage | ChangeTimeLimitMode;

/**
 * Change the time limit for a given stage.
 */
export interface ChangeTimeLimitForStage extends configure.Base {
  action: NameType;
  stage: round.Stage;
  timeLimit?: TimeLimit;
}

/**
 * Change the time limit mode, or disable the time limits completely.
 */
export interface ChangeTimeLimitMode extends configure.Base {
  action: NameType;
  mode: TimeLimitMode;
}

type NameType = "ChangeTimeLimit";
const name: NameType = "ChangeTimeLimit";

export const is = (action: Action): action is ChangeTimeLimit =>
  action.action === name;

export const isModeChange = (action: Action): action is ChangeTimeLimitMode =>
  is(action) && action.hasOwnProperty("mode");

export const isStageChange = (
  action: Action
): action is ChangeTimeLimitForStage =>
  is(action) && action.hasOwnProperty("stage");

export const handle: Handler<ChangeTimeLimit> = (auth, lobby, action) => {
  const lobbyRules = lobby.config.rules;
  const timeLimits = lobbyRules.timeLimits;
  if (isStageChange(action)) {
    switch (action.stage) {
      case "Playing":
        timeLimits.playing = action.timeLimit;
        break;
      case "Revealing":
        timeLimits.revealing = action.timeLimit;
        break;
      case "Judging":
        timeLimits.judging = action.timeLimit;
        break;
      case "Complete":
        if (action.timeLimit === undefined) {
          throw new InvalidActionError(
            "The complete stage must have a time limit."
          );
        }
        timeLimits.complete = action.timeLimit;
        break;
    }
    lobby.config.version += 1;
    return {
      lobby,
      events: [
        event.targetAll(
          timeLimitsChanged.forStage(
            lobby.config.version.toString(),
            action.stage,
            action.timeLimit
          )
        )
      ]
    };
  } else {
    lobbyRules.timeLimits.mode = action.mode;
    lobby.config.version += 1;
    return {
      lobby,
      events: [
        event.targetAll(
          timeLimitsChanged.mode(lobby.config.version.toString(), action.mode)
        )
      ]
    };
  }
};
