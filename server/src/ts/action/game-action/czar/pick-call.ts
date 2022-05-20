import type * as Card from "../../../games/cards/card.js";
import type * as Round from "../../../games/game/round.js";
import type * as Lobby from "../../../lobby.js";
import * as Actions from "../../actions.js";
import type * as Handler from "../../handler.js";
import type { Czar } from "../czar.js";

/**
 * A czar picks a call for a round.
 */
export interface PickCall {
  action: "PickCall";
  call: Card.Id;
  fill?: Card.Part[][];
}

class PickCallActions extends Actions.Implementation<
  Czar,
  PickCall,
  "PickCall",
  Lobby.WithActiveGame
> {
  protected readonly name = "PickCall";

  protected handle: Handler.Custom<PickCall, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action,
    server,
  ) => {
    const lobbyRound = lobby.game.round;

    if (lobbyRound.verifyStage<Round.Starting>(action, "Starting")) {
      const { round, events, timeouts } = lobbyRound.advance(
        server,
        lobby.game,
        action.call,
        action.fill,
      );
      lobby.game.round = round;
      return { lobby, events, timeouts };
    } else {
      return {};
    }
  };
}

export const actions = new PickCallActions();
