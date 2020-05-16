import * as Card from "../../games/cards/card";
import * as User from "../../user";

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
  replacement?: Card.Response
): CardDiscarded => ({
  event: "CardDiscarded",
  player,
  card,
  replacement,
});
