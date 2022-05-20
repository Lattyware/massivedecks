import { InvalidActionError } from "../../../errors/validation.js";
import * as Event from "../../../event.js";
import * as PlayTakenBack from "../../../events/game-event/play-taken-back.js";
import type * as Round from "../../../games/game/round.js";
import type * as Lobby from "../../../lobby.js";
import * as Actions from "../../actions.js";
import type * as Handler from "../../handler.js";
import type { Player } from "../player.js";

/**
 * A player plays a white card into a round.
 */
export interface TakeBack {
  action: "TakeBack";
}

class TakeBackActions extends Actions.Implementation<
  Player,
  TakeBack,
  "TakeBack",
  Lobby.WithActiveGame
> {
  protected readonly name = "TakeBack";

  protected handle: Handler.Custom<TakeBack, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action,
  ) => {
    if (lobby.game.round.verifyStage<Round.Playing>(action, "Playing")) {
      const plays = lobby.game.round.plays;
      const playIndex = plays.findIndex((play) => play.playedBy === auth.uid);
      if (playIndex < 0) {
        throw new InvalidActionError("No play to take back.");
      }
      plays.splice(playIndex, 1);
      return { lobby, events: [Event.targetAll(PlayTakenBack.of(auth.uid))] };
    } else {
      return {};
    }
  };
}

export const actions = new TakeBackActions();
