import * as Card from "../../games/cards/card";
import * as User from "../../user";

/**
 * Indicates a player has paid to redraw their hand under the Reboot house rule.
 */
export interface HandRedrawn extends Public {
  hand?: Card.PotentiallyBlankResponse[];
}

export interface Public {
  event: "HandRedrawn";
  player: User.Id;
}

export const of = (
  player: User.Id,
  hand?: Card.PotentiallyBlankResponse[]
): HandRedrawn => ({
  event: "HandRedrawn",
  player,
  ...(hand !== undefined ? { hand } : {})
});
