import * as Card from "../../../games/cards/card";
import * as Round from "../../../games/game/round";
import * as Lobby from "../../../lobby";
import * as Actions from "../../actions";
import * as Handler from "../../handler";
import { Czar } from "../czar";

/**
 * A czar picks a call for a round.
 */
export interface PickCall {
  action: "PickCall";
  call: Card.Id;
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
    server
  ) => {
    const lobbyRound = lobby.game.round;

    if (lobbyRound.verifyStage<Round.Starting>(action, "Starting")) {
      const { round, events, timeouts } = lobbyRound.advance(
        server,
        lobby.game,
        action.call
      );
      lobby.game.round = round;
      return { lobby, events, timeouts };
    } else {
      return {};
    }
  };
}

export const actions = new PickCallActions();
