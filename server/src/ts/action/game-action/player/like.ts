import * as Play from "../../../games/cards/play";
import * as Round from "../../../games/game/round";
import * as Lobby from "../../../lobby";
import * as Actions from "../../actions";
import * as Handler from "../../handler";
import { Player } from "../player";

/**
 * A player plays a white card into a round.
 */
export interface Like {
  action: "Like";
  play: Play.Id;
}

class LikeActions extends Actions.Implementation<
  Player,
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
      lobby.game.round.verifyStage<Round.Revealing | Round.Judging>(
        action,
        "Revealing",
        "Judging"
      )
    ) {
      const cRound = lobby.game.round;
      const target = cRound.plays.find((p) => p.id === action.play);
      if (
        target !== undefined &&
        target.playedBy !== auth.uid &&
        target.likes.find((id) => id === auth.uid) === undefined
      ) {
        target.likes.push(auth.uid);
        return {
          lobby,
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
