import * as configured from "../configured";

/**
 * The hand size in the rules for the lobby is changed.
 */
export interface HandSizeSet extends configured.Base {
  event: "HandSizeSet";
  handSize: number;
}
