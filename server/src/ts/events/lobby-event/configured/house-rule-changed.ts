import * as config from "../../../lobby/config";
import * as configured from "../configured";
import * as rules from "../../../games/rules";

/**
 * A change was made to a house rule in the lobby.
 */
export interface HouseRuleChanged extends configured.Base {
  event: "HouseRuleChanged";
  change: rules.Change;
}

export const of = (
  change: rules.Change,
  version: config.Version
): HouseRuleChanged => ({
  event: "HouseRuleChanged",
  change,
  version: version.toString()
});
