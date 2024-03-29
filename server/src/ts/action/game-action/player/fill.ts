import { IncorrectUserRoleError } from "../../../errors/action-execution-error.js";
import { InvalidActionError } from "../../../errors/validation.js";
import * as Card from "../../../games/cards/card.js";
import type * as Round from "../../../games/game/round.js";
import type * as Lobby from "../../../lobby.js";
import type { User } from "../../../user.js";
import * as Actions from "../../actions.js";
import type * as Handler from "../../handler.js";
import type { Player } from "../player.js";

/**
 * Indicates the user has changed the value of a blank card in their hand.
 */
export interface Fill {
  action: "Fill";
  card: Card.Id;
  text: string;
}

class FillActions extends Actions.Implementation<
  Player,
  Fill,
  "Fill",
  Lobby.WithActiveGame
> {
  protected readonly name = "Fill";

  protected handle: Handler.Custom<Fill, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action,
  ) => {
    const lobbyRound = lobby.game.round;
    if (lobbyRound.verifyStage<Round.Playing>(action, "Playing")) {
      const user = lobby.users[auth.uid] as User;
      const player = lobby.game.players[auth.uid];
      if (user.role !== "Player" || player === undefined) {
        throw new IncorrectUserRoleError(action, user.role, "Player");
      }
      const filled = player.hand.find((c) => c.id === action.card);
      if (filled === undefined) {
        throw new InvalidActionError(
          "The given card doesn't exist or isn't in the player's hand.",
        );
      }
      if (Card.isCustom(filled)) {
        filled.text = action.text;
        return { lobby };
      } else {
        throw new InvalidActionError("The given card isn't a custom card.");
      }
    } else {
      return {};
    }
  };
}

export const actions = new FillActions();
