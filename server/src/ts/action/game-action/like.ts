import * as Play from "../../games/cards/play";
import * as Round from "../../games/game/round";
import * as Lobby from "../../lobby";
import * as Actions from "../actions";
import * as Handler from "../handler";
import { GameAction } from "../game-action";
import * as PlayLiked from "../../events/game-event/play-liked";
import * as Event from "../../event";

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
    action
  ) => {
    if (
      lobby.game.round.verifyStage<
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
        lobby.game.players[target.playedBy].likes += 1;
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
