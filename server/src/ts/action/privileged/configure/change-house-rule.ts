import { Action } from "../../../action";
import * as event from "../../../event";
import * as rules from "../../../games/rules";
import { Handler } from "../../handler";
import * as configure from "../configure";
import * as houseRuleChanged from "../../../events/lobby-event/configured/house-rule-changed";

/**
 * Set the hand size for the lobby.
 */
export interface ChangeHouseRule extends configure.Base {
  action: NameType;
  change: rules.Change;
}

type NameType = "ChangeHouseRule";
const name: NameType = "ChangeHouseRule";

/**
 * Check if an action is an change decks action.
 * @param action The action to check.
 */
export const is = (action: Action): action is ChangeHouseRule =>
  action.action === name;

export const handle: Handler<ChangeHouseRule> = (auth, lobby, action) => {
  const houseRules = lobby.config.rules.houseRules;
  switch (action.change.houseRule) {
    case "PackingHeat":
      houseRules.packingHeat = action.change.settings;
      break;
    case "Rando":
      houseRules.rando = action.change.settings;
      break;
    case "Reboot":
      houseRules.reboot = action.change.settings;
      break;
  }
  lobby.config.version += 1;

  return {
    lobby,
    events: [
      event.target(houseRuleChanged.of(action.change, lobby.config.version))
    ]
  };
};
