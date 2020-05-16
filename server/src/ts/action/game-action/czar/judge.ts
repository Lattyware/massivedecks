import { InvalidActionError } from "../../../errors/validation";
import * as Event from "../../../event";
import * as RoundFinished from "../../../events/game-event/round-finished";
import * as Play from "../../../games/cards/play";
import * as Round from "../../../games/game/round";
import * as Lobby from "../../../lobby";
import * as RoundStart from "../../../timeout/round-start";
import * as Handler from "../../handler";
import { Czar } from "../czar";
import * as Actions from "./../../actions";

/**
 * A user declares the winning play for a round.
 */
export interface Judge {
  action: "Judge";
  winner: Play.Id;
}

class JudgeAction extends Actions.Implementation<
  Czar,
  Judge,
  "Judge",
  Lobby.WithActiveGame
> {
  protected readonly name = "Judge";

  protected handle: Handler.Custom<Judge, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action
  ) => {
    const game = lobby.game;
    const round = game.round;
    const plays = round.plays;
    if (round.verifyStage<Round.Judging>(action, "Judging")) {
      let winningPlay = undefined;
      for (const play of plays) {
        if (play.likes.length > 0) {
          const player = game.players[play.playedBy];
          player.likes += play.likes.length;
        }
        if (play.id === action.winner) {
          winningPlay = play;
        }
      }
      if (winningPlay === undefined) {
        throw new InvalidActionError("Given play doesn't exist.");
      }
      const player = game.players[winningPlay.playedBy];
      player.score += 1;
      const completedRound = round.advance(winningPlay.playedBy);
      game.round = completedRound;
      game.history.splice(0, 0, completedRound.public());

      return {
        lobby,
        events: [Event.targetAll(RoundFinished.of(completedRound))],
        timeouts: [
          {
            timeout: RoundStart.of(),
            after: game.rules.stages.judging.after * 1000,
          },
        ],
      };
    } else {
      return {};
    }
  };
}

export const actions = new JudgeAction();
