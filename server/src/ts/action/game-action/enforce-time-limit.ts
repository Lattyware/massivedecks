import { Action } from "../../action";
import { InvalidActionError } from "../../errors/validation";
import * as round from "../../games/game/round";
import * as Lobby from "../../lobby";
import * as change from "../../lobby/change";
import * as gameAction from "../game-action";
import { dealWithLostPlayer } from "./set-presence";

/**
 * A player asks to enforce the soft time limit for the game.
 */
export interface EnforceTimeLimit {
  action: "EnforceTimeLimit";
  round: string;
  stage: round.Stage;
}

type NameType = "EnforceTimeLimit";
const name: NameType = "EnforceTimeLimit";

export const is = (action: Action): action is EnforceTimeLimit =>
  action.action === name;

export const handle: gameAction.Handler<EnforceTimeLimit> = (
  auth,
  lobby,
  action,
  server
) => {
  const timeLimits = lobby.config.rules.timeLimits;
  const game = lobby.game;
  if (timeLimits === undefined || timeLimits.mode === "Hard") {
    // No time limit to enforce, or they are automatically enforced.
    throw new InvalidActionError("No time limits to enforce.");
  }
  const gameRound = game.round;
  if (
    gameRound.id.toString() !== action.round ||
    gameRound.stage !== action.stage ||
    !round.isTimed(gameRound)
  ) {
    return {};
  }
  const waitingFor = gameRound.waitingFor();
  if (waitingFor === null) {
    // We are done.
    return {};
  }
  if (gameRound.timedOut) {
    return change.reduce(waitingFor, lobby as Lobby.WithActiveGame, (l, p) =>
      dealWithLostPlayer(server, l, p)
    );
  } else {
    throw new InvalidActionError("Round stage timer not done.");
  }
};
