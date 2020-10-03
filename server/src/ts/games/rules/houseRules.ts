import { PackingHeat, Reboot, ComedyWriter, NeverHaveIEver, HappyEnding } from "../rules";
import * as Rando from "./rando";

/**
 * Non-standard rules that can be applied to a game.
 */
export interface HouseRules {
  packingHeat?: PackingHeat;
  reboot?: Reboot;
  comedyWriter?: ComedyWriter;
  rando: Rando.Rando;
  neverHaveIEver?: NeverHaveIEver;
  happyEnding?: HappyEnding;
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
  happyEnding?: HappyEnding;
}

export const censor = (houseRules: HouseRules): Public => ({
  ...houseRules,
  rando: Rando.censor(houseRules.rando),
});
