import { Action } from "../../../action";
import { InvalidActionError } from "../../../errors/validation";
import * as event from "../../../event";
import * as playTakenBack from "../../../events/game-event/play-taken-back";
import * as gameAction from "../../game-action";
import * as round from "../../../games/game/round";

/**
 * A player plays a white card into a round.
 */
export interface TakeBack {
  action: "TakeBack";
}

type NameType = "TakeBack";
const name: NameType = "TakeBack";

/**
 * Check if an action is a take back action.
 * @param action The action to check.
 */
export const is = (action: Action): action is TakeBack =>
  action.action === name;

export const handle: gameAction.Handler<TakeBack> = (auth, lobby, action) => {
  if (round.verifyStage<round.Playing>(action, lobby.game.round, "Playing")) {
    const plays = lobby.game.round.plays;
    const playIndex = plays.findIndex(play => play.playedBy === auth.uid);
    if (playIndex < 0) {
      throw new InvalidActionError("No play to take back.");
    }
    plays.splice(playIndex, 1);
    return { lobby, events: [event.targetAll(playTakenBack.of(auth.uid))] };
  } else {
    return {};
  }
};
