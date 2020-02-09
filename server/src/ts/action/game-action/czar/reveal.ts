import { InvalidActionError } from "../../../errors/validation";
import * as Event from "../../../event";
import * as PlayRevealed from "../../../events/game-event/play-revealed";
import * as Play from "../../../games/cards/play";
import * as Round from "../../../games/game/round";
import * as Lobby from "../../../lobby";
import * as RoundStageTimerDone from "../../../timeout/round-stage-timer-done";
import * as Handler from "../../handler";
import { Czar } from "../czar";
import * as Actions from "./../../actions";

/**
 * A user judges the winning play for a round.
 */
export interface Reveal {
  action: "Reveal";
  play: Play.Id;
}

class RevealAction extends Actions.Implementation<
  Czar,
  Reveal,
  "Reveal",
  Lobby.WithActiveGame
> {
  protected readonly name = "Reveal";

  protected handle: Handler.Custom<Reveal, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action
  ) => {
    const lobbyRound = lobby.game.round;
    if (lobbyRound.verifyStage<Round.Revealing>(action, "Revealing")) {
      const play = lobbyRound.plays.find(play => play.id === action.play);
      if (play === undefined) {
        throw new InvalidActionError("Given play doesn't exist.");
      }
      if (play.revealed) {
        return {};
      }
      play.revealed = true;
      const timeouts = [];
      const advancedRound = lobbyRound.advance();
      if (advancedRound !== null) {
        lobby.game.round = advancedRound;
        const timer = RoundStageTimerDone.ifEnabled(
          lobbyRound,
          lobby.game.rules.timeLimits
        );
        if (timer !== undefined) {
          timeouts.push(timer);
        }
      }
      return {
        lobby,
        events: [Event.targetAll(PlayRevealed.of(play.id, play.play))],
        timeouts: timeouts
      };
    } else {
      return {};
    }
  };
}

export const actions = new RevealAction();
