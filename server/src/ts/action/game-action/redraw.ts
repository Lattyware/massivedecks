import { IncorrectUserRoleError } from "../../errors/action-execution-error";
import { InvalidActionError } from "../../errors/validation";
import * as Event from "../../event";
import * as HandRedrawn from "../../events/game-event/hand-redrawn";
import * as Lobby from "../../lobby";
import * as Actions from "../actions";
import * as GameAction from "../game-action";
import * as Handler from "../handler";

/**
 * A player plays a white card into a round.
 */
export interface Redraw {
  action: "Redraw";
}

class RedrawActions extends Actions.Implementation<
  GameAction.GameAction,
  Redraw,
  "Redraw",
  Lobby.WithActiveGame
> {
  protected readonly name = "Redraw";

  protected handle: Handler.Custom<Redraw, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action
  ) => {
    const game = lobby.game;
    const reboot = game.rules.houseRules.reboot;
    if (reboot === undefined) {
      throw new InvalidActionError("Redraw house rule not enabled.");
    }
    const cost = reboot.cost;
    const player = game.players[auth.uid];
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
      events: [
        Event.additionally(
          HandRedrawn.of(auth.uid),
          new Map([[auth.uid, { hand: player.hand }]])
        ),
      ],
    };
  };
}

export const actions = new RedrawActions();
