import type {
  ComedyWriter,
  NeverHaveIEver,
  PackingHeat,
  Reboot,
} from "../rules.js";
import type * as CzarChoices from "./czar-choices.js";
import type * as HappyEnding from "./happy-ending.js";
import * as Rando from "./rando.js";
import type * as WinnersPick from "./winners-pick.js";

/**
 * Non-standard rules that can be applied to a game.
 */
export interface HouseRules {
  packingHeat?: PackingHeat;
  reboot?: Reboot;
  comedyWriter?: ComedyWriter;
  rando: Rando.Rando;
  neverHaveIEver?: NeverHaveIEver;
  happyEnding?: HappyEnding.HappyEnding;
  czarChoices?: CzarChoices.CzarChoices;
  winnersPick?: WinnersPick.WinnersPick;
}

/**
 * The public view of the internal model.
 */
export interface Public {
  packingHeat?: PackingHeat;
  reboot?: Reboot;
  comedyWriter?: ComedyWriter;
  rando?: Rando.Public;
  neverHaveIEver?: NeverHaveIEver;
  happyEnding?: HappyEnding.HappyEnding;
  czarChoices?: CzarChoices.CzarChoices;
  winnersPick?: WinnersPick.WinnersPick;
}

export const censor = (houseRules: HouseRules): Public => ({
  ...houseRules,
  rando: Rando.censor(houseRules.rando),
});
