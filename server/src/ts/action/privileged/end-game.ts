import * as Actions from "./../actions";
import * as Event from "../../event";
import * as GameEnded from "../../events/game-event/game-ended";
import * as Lobby from "../../lobby";
import * as Handler from "../handler";
import { Privileged } from "../privileged";

/**
 * End the current game.
 */
export interface EndGame {
  action: "EndGame";
}

class EndGameActions extends Actions.Implementation<
  Privileged,
  EndGame,
  "EndGame",
  Lobby.Lobby
> {
  protected readonly name = "EndGame";

  protected handle: Handler.Custom<EndGame, Lobby.Lobby> = (
    auth,
    lobby,
    action
  ) => {
    if (lobby.game === undefined || lobby.game.winner !== undefined) {
      // If we are asked to end a game that isn't started or is already ended,
      // just forget it.
      return {};
    }
    let max = 0;
    const winners = [];
    for (const [id, player] of Object.entries(lobby.game.players)) {
      if (player.score > max) {
        max = player.score;
        winners.length = 0;
      }
      if (player.score === max) {
        winners.push(id);
      }
    }
    lobby.game.winner = winners;
    return {
      lobby,
      events: [Event.targetAll(GameEnded.of(...winners))],
    };
  };
}

export const actions = new EndGameActions();
