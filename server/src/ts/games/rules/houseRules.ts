import { PackingHeat, Reboot } from "../rules";
import * as rando from "./rando";
import { Rando } from "./rando";

/**
 * Non-standard rules that can be applied to a game.
 */
export interface HouseRules {
  packingHeat?: PackingHeat;
  reboot?: Reboot;
  rando: Rando;
}

/**
 * The public view of the internal model.
 */
export interface Public {
  packingHeat?: PackingHeat;
  reboot?: Reboot;
  rando?: rando.Public;
}

export const create = (): HouseRules => ({
  rando: rando.create()
});

export const censor = (houseRules: HouseRules): Public => ({
  ...houseRules,
  rando: rando.censor(houseRules.rando)
});
