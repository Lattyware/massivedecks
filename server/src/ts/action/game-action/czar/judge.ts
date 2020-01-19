import { Action } from "../../../action";
import { InvalidActionError } from "../../../errors/validation";
import * as event from "../../../event";
import * as roundFinished from "../../../events/game-event/round-finished";
import * as play from "../../../games/cards/play";
import * as round from "../../../games/game/round";
import { Player } from "../../../games/player";
import * as roundStart from "../../../timeout/round-start";
import * as gameAction from "../../game-action";

/**
 * A user declares the winning play for a round.
 */
export interface Judge {
  action: NameType;
  winner: play.Id;
}

type NameType = "Judge";
const name: NameType = "Judge";

export const is = (action: Action): action is Judge => action.action === name;

export const handle: gameAction.Handler<Judge> = (auth, lobby, action) => {
  const game = lobby.game;
  const lobbyRound = game.round;
  const plays = lobbyRound.plays;
  if (lobbyRound.verifyStage<round.Judging>(action, "Judging")) {
    let winningPlay = undefined;
    for (const play of plays) {
      if (play.likes.size > 0) {
        const player = game.players.get(play.playedBy) as Player;
        player.likes += play.likes.size;
      }
      if (play.id === action.winner) {
        winningPlay = play;
      }
    }
    if (winningPlay === undefined) {
      throw new InvalidActionError("Given play doesn't exist.");
    }
    const player = game.players.get(winningPlay.playedBy) as Player;
    player.score += 1;
    const completedRound = lobbyRound.advance(winningPlay.playedBy);
    game.round = completedRound;
    game.history.splice(0, 0, completedRound.public());

    return {
      lobby,
      events: [event.targetAll(roundFinished.of(completedRound))],
      timeouts: [
        {
          timeout: roundStart.of(),
          after: game.rules.timeLimits.complete * 1000
        }
      ]
    };
  } else {
    return {};
  }
};
