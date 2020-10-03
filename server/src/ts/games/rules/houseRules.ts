import { PackingHeat, Reboot, ComedyWriter, NeverHaveIEver } from "../rules";
import * as Rando from "./rando";
import * as HappyEnding from "./happyEnding";

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
}

export const censor = (houseRules: HouseRules): Public => ({
  ...houseRules,
  rando: Rando.censor(houseRules.rando),
});
