import type * as Card from "../../games/cards/card.js";
import type * as User from "../../user.js";

/**
 * Indicates a player has paid to redraw their hand under the Reboot house rule.
 */
export interface HandRedrawn extends Public {
  hand?: Card.Response[];
}

export interface Public {
  event: "HandRedrawn";
  player: User.Id;
}

export const of = (player: User.Id, hand?: Card.Response[]): HandRedrawn => ({
  event: "HandRedrawn",
  player,
  ...(hand !== undefined ? { hand } : {}),
});
