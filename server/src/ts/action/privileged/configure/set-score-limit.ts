import { Action } from "../../../action";
import * as event from "../../../event";
import { ScoreLimitSet } from "../../../events/lobby-event/configured/score-limit-set";
import { Handler } from "../../handler";
import * as configure from "../configure";

/**
 * (Un)Set the score limit for the lobby.
 */
export interface SetScoreLimit extends configure.Base {
  action: NameType;
  /**
   * The score threshold for the game - when a player hits this they win.
   * If not set, then there is end - the game goes on infinitely.
   * @TJS-type integer
   * @minimum 1
   */
  scoreLimit?: number;
}

type NameType = "SetScoreLimit";
const name: NameType = "SetScoreLimit";

/**
 * Check if an action is an change decks action.
 * @param action The action to check.
 */
export const is = (action: Action): action is SetScoreLimit =>
  action.action === name;

export const handle: Handler<SetScoreLimit> = (auth, lobby, action) => {
  const config = lobby.config;
  if (config.rules.scoreLimit !== action.scoreLimit) {
    const version = config.version + 1;
    const scoreLimitSet: ScoreLimitSet = {
      event: "ScoreLimitSet",
      version: version.toString()
    };
    if (action.scoreLimit !== undefined) {
      config.rules.scoreLimit = action.scoreLimit;
      scoreLimitSet.scoreLimit = action.scoreLimit;
    } else {
      delete config.rules.scoreLimit;
    }
    config.version = version;
    return { lobby, events: [event.target(scoreLimitSet)] };
  } else {
    return {};
  }
};
