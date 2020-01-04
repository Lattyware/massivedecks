import { Action } from "../../../action";
import { InvalidActionError } from "../../../errors/validation";
import * as event from "../../../event";
import * as playRevealed from "../../../events/game-event/play-revealed";
import * as play from "../../../games/cards/play";
import * as round from "../../../games/game/round";
import * as gameAction from "../../game-action";

/**
 * A user judges the winning play for a round.
 */
export interface Reveal {
  action: NameType;
  play: play.Id;
}

type NameType = "Reveal";
const name: NameType = "Reveal";

/**
 * Check if an action is a reveal action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Reveal => action.action === name;

/**
 * Handle a Judge action.
 * @param auth The claims for the user attempting to perform the action.
 * @param lobby The lobby the user is attempting to perform the action in.
 * @param action The action.
 */
export const handle: gameAction.Handler<Reveal> = (auth, lobby, action) => {
  const lobbyRound = lobby.game.round;
  if (lobbyRound.verifyStage<round.Revealing>(action, "Revealing")) {
    const play = lobbyRound.plays.find(play => play.id === action.play);
    if (play === undefined) {
      throw new InvalidActionError("Given play doesn't exist.");
    }
    if (play.revealed) {
      return {};
    }
    play.revealed = true;
    const advancedRound = lobbyRound.advance();
    if (advancedRound !== null) {
      lobby.game.round = advancedRound;
    }
    return {
      lobby,
      events: [event.targetAll(playRevealed.of(play.id, play.play))]
    };
  } else {
    return {};
  }
};
