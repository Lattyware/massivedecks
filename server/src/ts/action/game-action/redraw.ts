import { Action } from "../../action";
import { IncorrectUserRoleError } from "../../errors/action-execution-error";
import { InvalidActionError } from "../../errors/validation";
import * as event from "../../event";
import * as handRedrawn from "../../events/game-event/hand-redrawn";
import * as gameAction from "../game-action";

/**
 * A player plays a white card into a round.
 */
export interface Redraw {
  action: "Redraw";
}

type NameType = "Redraw";
const name: NameType = "Redraw";

/**
 * Check if an action is a take back action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Redraw => action.action === name;

export const handle: gameAction.Handler<Redraw> = (auth, lobby, action) => {
  const game = lobby.game;
  const reboot = game.rules.houseRules.reboot;
  if (reboot === undefined) {
    throw new InvalidActionError("Redraw house rule not enabled.");
  }
  const cost = reboot.cost;
  const player = game.players.get(auth.uid);
  if (player === undefined) {
    throw new IncorrectUserRoleError(action, "Spectator", "Player");
  }
  if (player.score < cost) {
    throw new InvalidActionError("Can't afford to redraw.");
  }
  player.score -= cost;
  player.hand = game.decks.responses.replace(...player.hand);
  return {
    lobby,
    events: event.targetByPlayer(
      auth.uid,
      handRedrawn.of(auth.uid, player.hand),
      handRedrawn.censor
    )
  };
};
