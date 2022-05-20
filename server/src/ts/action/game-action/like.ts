import * as Event from "../../event.js";
import * as PlayLiked from "../../events/game-event/play-liked.js";
import type * as Play from "../../games/cards/play.js";
import type * as Round from "../../games/game/round.js";
import type { Player } from "../../games/player.js";
import type * as Lobby from "../../lobby.js";
import * as Actions from "../actions.js";
import type { GameAction } from "../game-action.js";
import type * as Handler from "../handler.js";

/**
 * A player or spectator likes a play.
 */
export interface Like {
  action: "Like";
  play: Play.Id;
}

class LikeActions extends Actions.Implementation<
  GameAction,
  Like,
  "Like",
  Lobby.WithActiveGame
> {
  protected readonly name = "Like";

  protected handle: Handler.Custom<Like, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action,
  ) => {
    if (
      lobby.game.round.isInStage<
        Round.Revealing | Round.Judging | Round.Complete
      >(action, "Revealing", "Judging", "Complete")
    ) {
      const cRound = lobby.game.round;
      const target = cRound.plays.find((p) => p.id === action.play);
      if (
        target !== undefined &&
        target.playedBy !== auth.uid &&
        target.likes.find((id) => id === auth.uid) === undefined
      ) {
        (lobby.game.players[target.playedBy] as Player).likes += 1;
        target.likes.push(auth.uid);
        const events =
          lobby.game.round.stage === "Complete"
            ? [Event.targetAll(PlayLiked.of(action.play))]
            : [];
        return {
          lobby,
          events,
        };
      } else {
        return {};
      }
    } else {
      return {};
    }
  };
}

export const actions = new LikeActions();
