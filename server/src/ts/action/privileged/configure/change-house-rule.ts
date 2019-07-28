import { Action } from "../../../action";
import * as event from "../../../event";
import * as rules from "../../../games/rules";
import { Handler } from "../../handler";
import * as configure from "../configure";
import * as houseRuleChanged from "../../../events/lobby-event/configured/house-rule-changed";
import * as rando from "../../../games/rules/rando";

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
  const hr = lobby.config.rules.houseRules;
  const events = [];
  let changed = false;
  switch (action.change.houseRule) {
    case "PackingHeat":
      if (hr.packingHeat !== action.change.settings) {
        hr.packingHeat = action.change.settings;
        changed = true;
      }
      break;
    case "Rando":
      const userEvents = rando.change(lobby, hr.rando, action.change.settings);
      if (userEvents !== null) {
        events.push(...userEvents);
        changed = true;
      }
      break;
    case "Reboot":
      if (hr.reboot !== action.change.settings) {
        hr.reboot = action.change.settings;
        changed = true;
      }
      break;
  }
  if (changed) {
    lobby.config.version += 1;
    events.push(
      event.targetAll(houseRuleChanged.of(action.change, lobby.config.version))
    );
    return {
      lobby,
      events
    };
  } else {
    return {};
  }
};
