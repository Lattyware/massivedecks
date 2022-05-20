import type * as Card from "../../games/cards/card.js";
import type * as User from "../../user.js";

/**
 * Indicates a player has paid to redraw their hand under the Reboot house rule.
 */
export interface CardDiscarded {
  event: "CardDiscarded";
  player: User.Id;
  card: Card.Response;
  replacement?: Card.Response;
}

export const of = (
  player: User.Id,
  card: Card.Response,
  replacement?: Card.Response,
): CardDiscarded => ({
  event: "CardDiscarded",
  player,
  card,
  replacement,
});
