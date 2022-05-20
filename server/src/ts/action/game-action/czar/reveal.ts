import { InvalidActionError } from "../../../errors/validation.js";
import * as Event from "../../../event.js";
import * as PlayRevealed from "../../../events/game-event/play-revealed.js";
import type * as Play from "../../../games/cards/play.js";
import type * as Round from "../../../games/game/round.js";
import * as StoredPlay from "../../../games/game/round/stored-play.js";
import type * as Lobby from "../../../lobby.js";
import * as FinishedRevealing from "../../../timeout/finished-revealing.js";
import * as Util from "../../../util.js";
import type * as Handler from "../../handler.js";
import type { Czar } from "../czar.js";
import * as Actions from "./../../actions.js";

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
    action,
  ) => {
    const game = lobby.game;
    if (game.round.verifyStage<Round.Revealing>(action, "Revealing")) {
      const play = game.round.plays.find((play) => play.id === action.play);
      if (play === undefined) {
        throw new InvalidActionError("Given play doesn't exist.");
      }
      if (play.revealed) {
        return {};
      }
      play.revealed = true;
      const timeouts = Util.asOptionalIterable(
        StoredPlay.allRevealed(game.round)
          ? FinishedRevealing.of(game.rules.stages)
          : undefined,
      );
      return {
        lobby,
        events: [Event.targetAll(PlayRevealed.of(play.id, play.play))],
        timeouts: timeouts,
      };
    } else {
      return {};
    }
  };
}

export const actions = new RevealAction();
