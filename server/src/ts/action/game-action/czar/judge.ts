import { InvalidActionError } from "../../../errors/validation.js";
import * as Event from "../../../event.js";
import * as RoundFinished from "../../../events/game-event/round-finished.js";
import type * as Play from "../../../games/cards/play.js";
import type * as Round from "../../../games/game/round.js";
import type { Player } from "../../../games/player.js";
import type * as Lobby from "../../../lobby.js";
import * as RoundStart from "../../../timeout/round-start.js";
import type * as Handler from "../../handler.js";
import type { Czar } from "../czar.js";
import * as Actions from "./../../actions.js";

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
    action,
  ) => {
    const game = lobby.game;
    const round = game.round;
    if (round.verifyStage<Round.Judging>(action, "Judging")) {
      const plays = round.plays;
      let winningPlay = undefined;
      for (const play of plays) {
        if (play.likes.length > 0) {
          const player = game.players[play.playedBy] as Player;
          player.likes += play.likes.length;
        }
        if (play.id === action.winner) {
          winningPlay = play;
        }
      }
      if (winningPlay === undefined) {
        throw new InvalidActionError("Given play doesn't exist.");
      }
      const player = game.players[winningPlay.playedBy] as Player;
      player.score += 1;
      if (game.rules.houseRules.winnersPick) {
        game.rules.houseRules.winnersPick.roundWinner = winningPlay.playedBy;
      }
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
