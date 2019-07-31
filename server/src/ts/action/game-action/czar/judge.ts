import { Action } from "../../../action";
import { InvalidActionError } from "../../../errors/validation";
import * as roundFinished from "../../../events/game-event/round-finished";
import * as play from "../../../games/cards/play";
import * as round from "../../../games/game/round";
import * as gameAction from "../../game-action";
import * as event from "../../../event";
import * as roundStart from "../../../timeout/round-start";

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

export const handle: gameAction.Handler<Judge> = (
  auth,
  lobby,
  action,
  server
) => {
  const lobbyRound = lobby.game.round;
  const plays = lobbyRound.plays;
  if (round.verifyStage<round.Judging>(action, lobbyRound, "Judging")) {
    const play = plays.find(play => play.id === action.winner);
    if (play === undefined) {
      throw new InvalidActionError("Given play doesn't exist.");
    }
    const player = lobby.game.players.get(play.playedBy);
    if (player !== undefined) {
      player.score += 1;
    }
    const completedRound: round.Complete = {
      ...lobbyRound,
      stage: "Complete",
      winner: play.playedBy
    };
    lobby.game.round = completedRound;
    lobby.game.history.splice(0, 0, completedRound);
    return {
      lobby,
      events: [event.targetAll(roundFinished.of(completedRound))],
      timeouts: [
        {
          timeout: roundStart.of(),
          after: server.config.timeouts.nextRoundDelay
        }
      ]
    };
  } else {
    return {};
  }
};
