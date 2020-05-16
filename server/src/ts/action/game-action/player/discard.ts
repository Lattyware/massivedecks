import * as Card from "../../../games/cards/card";
import * as Actions from "../../actions";
import { Player } from "../player";
import * as Lobby from "../../../lobby";
import * as Handler from "../../handler";
import { InvalidActionError } from "../../../errors/validation";
import * as Util from "../../../util";
import * as Event from "../../../event";
import * as CardDiscarded from "../../../events/game-event/card-discarded";

/**
 * Indicates the user is discarding their hand.
 */
export interface Discard {
  action: "Discard";
  card: Card.Id;
}

class DiscardActions extends Actions.Implementation<
  Player,
  Discard,
  "Discard",
  Lobby.WithActiveGame
> {
  protected readonly name = "Discard";

  protected handle: Handler.Custom<Discard, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action
  ) => {
    if (lobby.game.rules.houseRules.neverHaveIEver === undefined) {
      throw new InvalidActionError(
        "The “Never Have I Ever” house rule is not enabled this game, but must be to do that."
      );
    }
    const id = auth.uid;
    const player = lobby.game.players[id];
    const card = player.hand.find((c) => c.id === action.card);
    if (card === undefined) {
      throw new InvalidActionError("Must have the card to discard it.");
    }
    player.hand = player.hand.filter((c) => c.id !== action.card);
    const [replacement] = lobby.game.decks.responses.replace(card);
    player.hand.push(replacement);
    const events = Util.asOptionalIterable(
      Event.playerSpecificAddition(CardDiscarded.of(id, card), (to) =>
        id === to ? { replacement } : {}
      )
    );
    return { events };
  };
}

export const actions = new DiscardActions();
