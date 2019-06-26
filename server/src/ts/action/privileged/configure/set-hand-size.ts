import { Action } from "../../../action";
import * as event from "../../../event";
import { Handler } from "../../handler";
import * as configure from "../configure";

/**
 * Set the hand size for the lobby.
 */
export interface SetHandSize extends configure.Base {
  action: NameType;
  /**
   * The number of cards in each player's hand.
   * @TJS-type integer
   * @minimum 3
   */
  handSize: number;
}

type NameType = "SetHandSize";
const name: NameType = "SetHandSize";

/**
 * Check if an action is an change decks action.
 * @param action The action to check.
 */
export const is = (action: Action): action is SetHandSize =>
  action.action === name;

export const handle: Handler<SetHandSize> = (auth, lobby, action) => {
  const config = lobby.config;
  if (config.rules.handSize !== action.handSize) {
    config.rules.handSize = action.handSize;
    config.version += 1;
    return {
      lobby,
      events: [
        event.targetAll({
          event: "HandSizeSet",
          handSize: action.handSize,
          version: config.version.toString()
        })
      ]
    };
  } else {
    return {};
  }
};
