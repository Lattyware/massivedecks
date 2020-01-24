import * as card from "../../games/cards/card";
import * as user from "../../user";

/**
 * Indicates a player has paid to redraw their hand under the Reboot house rule.
 */
export interface HandRedrawn extends Public {
  hand?: card.PotentiallyBlankResponse[];
}

export interface Public {
  event: "HandRedrawn";
  player: user.Id;
}

export const of = (
  player: user.Id,
  hand?: card.PotentiallyBlankResponse[]
): HandRedrawn => ({
  event: "HandRedrawn",
  player,
  ...(hand !== undefined ? { hand } : {})
});
