import { InvalidActionError } from "../../errors/validation.js";
import * as round from "../../games/game/round.js";
import type * as Lobby from "../../lobby.js";
import * as change from "../../lobby/change.js";
import * as Actions from "../actions.js";
import type { GameAction } from "../game-action.js";
import type * as Handler from "../handler.js";
import { dealWithLostPlayer } from "./set-presence.js";

/**
 * A player asks to enforce the soft time limit for the game.
 */
export interface EnforceTimeLimit {
  action: "EnforceTimeLimit";
  round: string;
  stage: round.Stage;
}

class EnforceTimeLimitAction extends Actions.Implementation<
  GameAction,
  EnforceTimeLimit,
  "EnforceTimeLimit",
  Lobby.WithActiveGame
> {
  protected readonly name = "EnforceTimeLimit";

  protected handle: Handler.Custom<EnforceTimeLimit, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action,
    server,
  ) => {
    const game = lobby.game;
    const stages = game.rules.stages;
    if (stages.timeLimitMode === "Hard") {
      // Time limits are automatically enforced, so we don't need to do anything.
      return {};
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
        dealWithLostPlayer(server, l, p),
      );
    } else {
      throw new InvalidActionError("Round stage timer not done.");
    }
  };
}

export const actions = new EnforceTimeLimitAction();
