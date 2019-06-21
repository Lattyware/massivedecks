import wu from "wu";
import { Action } from "../../../action";
import { IncorrectUserRoleError } from "../../../errors/action-execution-error";
import { InvalidActionError } from "../../../errors/validation";
import * as event from "../../../event";
import * as playSubmitted from "../../../events/game-event/play-submitted";
import * as card from "../../../games/cards/card";
import * as play from "../../../games/cards/play";
import { Play } from "../../../games/cards/play";
import * as finishedPlaying from "../../../timeout/finished-playing";
import * as gameAction from "../../game-action";
import * as round from "../../../games/game/round";

/**
 * A player plays a white card into a round.
 */
export interface Submit {
  action: "Submit";
  play: card.Id[];
}

type NameType = "Submit";
const name: NameType = "Submit";

/**
 * Check if an action is a submit action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Submit => action.action === name;

export const handle: gameAction.Handler<Submit> = (
  auth,
  lobby,
  action,
  server
) => {
  const lobbyRound = lobby.game.round;
  if (round.verifyStage<round.Playing>(action, lobbyRound, "Playing")) {
    const playId = play.id();
    const plays = lobbyRound.plays;
    if (plays.find(play => play.playedBy === auth.uid)) {
      throw new InvalidActionError("Already played into round.");
    }
    const playLength = action.play.length;
    const slotCount = card.slotCount(lobbyRound.call);
    if (playLength !== slotCount) {
      throw new InvalidActionError(
        "The play must have the same number of responses as the call " +
          `has slots (expected ${slotCount}, got ${playLength}).`
      );
    }
    const player = lobby.game.players.get(auth.uid);
    if (player === undefined) {
      throw new IncorrectUserRoleError(action, "Spectator", "Player");
    }
    const ids = new Set(action.play);
    const extractedPlay: Play = [];
    for (const playedId of ids) {
      const played = player.hand.find(card => card.id === playedId);
      if (played === undefined) {
        throw new InvalidActionError(
          "The given card doesn't exist or isn't in the player's hand."
        );
      }
      extractedPlay.push(played);
    }
    plays.push({
      id: playId,
      play: extractedPlay,
      playedBy: auth.uid,
      revealed: false
    });
    const events = [event.target(playSubmitted.of(auth.uid))];
    const timeouts = [];
    const timeout = finishedPlaying.ifNeeded(lobbyRound);
    if (timeout !== undefined) {
      timeouts.push({
        timeout: timeout,
        after: server.config.timeouts.nextRoundDelay
      });
    }
    return { lobby, events, timeouts };
  } else {
    return {};
  }
};
