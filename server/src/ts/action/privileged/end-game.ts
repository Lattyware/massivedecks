import { Action } from "../../action";
import * as event from "../../event";
import * as gameEnded from "../../events/game-event/game-ended";
import { Handler } from "../handler";

/**
 * End the current game.
 */
export interface EndGame {
  action: NameType;
}

type NameType = "EndGame";
const name: NameType = "EndGame";

export const is = (action: Action): action is EndGame => action.action === name;

export const handle: Handler<EndGame> = (auth, lobby) => {
  if (lobby.game === undefined || lobby.game.winner !== undefined) {
    // If we are asked to end a game that isn't started or is already ended,
    // just forget it.
    return {};
  }
  let max = 0;
  const winners = [];
  for (const [id, player] of lobby.game.players) {
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
    events: [event.targetAll(gameEnded.of(...winners))]
  };
};
