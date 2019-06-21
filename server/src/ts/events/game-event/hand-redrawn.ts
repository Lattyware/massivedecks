import * as card from "../../games/cards/card";
import * as user from "../../user";

/**
 * Indicates a player has paid to redraw their hand under the Reboot house rule.
 */
export interface HandRedrawn extends Public {
  hand?: card.Response[];
}

export interface Public {
  event: "HandRedrawn";
  player: user.Id;
}

export const of = (player: user.Id, hand: card.Response[]): HandRedrawn => ({
  event: "HandRedrawn",
  player,
  hand
});

export const censor = (event: HandRedrawn): Public => ({
  event: event.event,
  player: event.player
});
