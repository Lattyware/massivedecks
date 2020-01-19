import { Action } from "../../../action";
import * as round from "../../../games/game/round";
import * as gameAction from "../../game-action";
import * as play from "../../../games/cards/play";

/**
 * A player plays a white card into a round.
 */
export interface Like {
  action: NameType;
  play: play.Id;
}

type NameType = "Like";
const name: NameType = "Like";

/**
 * Check if an action is a take back action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Like => action.action === name;

export const handle: gameAction.Handler<Like> = (auth, lobby, action) => {
  if (
    lobby.game.round.verifyStage<round.Revealing | round.Judging>(
      action,
      "Judging"
    )
  ) {
    const cRound = lobby.game.round;
    const target = cRound.plays.find(p => p.id === action.play);
    if (
      target !== undefined &&
      target.playedBy !== auth.uid &&
      !target.likes.has(auth.uid)
    ) {
      target.likes.add(auth.uid);
      return {
        lobby
      };
    } else {
      return {};
    }
  } else {
    return {};
  }
};
