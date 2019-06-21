import wu from "wu";
import { Action } from "../../action";
import { ConfigEditConflictError } from "../../errors/action-execution-error";
import { Handler } from "../handler";
import { ChangeDecks } from "./configure/change-decks";
import * as changeDecks from "./configure/change-decks";
import * as setHandSize from "./configure/set-hand-size";
import { SetHandSize } from "./configure/set-hand-size";
import * as setPassword from "./configure/set-password";
import { SetPassword } from "./configure/set-password";
import * as setScoreLimit from "./configure/set-score-limit";
import { SetScoreLimit } from "./configure/set-score-limit";
import * as changeHouseRule from "./configure/change-house-rule";
import { ChangeHouseRule } from "./configure/change-house-rule";

/**
 * An action to change the configuration of the lobby.
 */
export type Configure =
  | SetPassword
  | SetHandSize
  | SetScoreLimit
  | ChangeDecks
  | ChangeHouseRule;

const possible = new Set([
  setPassword.is,
  setHandSize.is,
  setScoreLimit.is,
  changeDecks.is,
  changeHouseRule.is
]);

/**
 * Check if an action is a configure action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Configure =>
  wu(possible).some(is => is(action));

/**
 * A base for all config actions.
 */
export interface Base {
  /**
   * If the config version doesn't match this, the operation will be rejected.
   * This avoids users accidentally overwriting each other's changes.
   */
  if: string;
}

export const handle: Handler<Configure> = (auth, lobby, action, config) => {
  const version = lobby.config.version.toString();
  if (action.if !== version) {
    throw new ConfigEditConflictError(action, action.if, version);
  }
  switch (action.action) {
    case "SetPassword":
      return setPassword.handle(auth, lobby, action, config);
    case "SetHandSize":
      return setHandSize.handle(auth, lobby, action, config);
    case "SetScoreLimit":
      return setScoreLimit.handle(auth, lobby, action, config);
    case "ChangeDecks":
      return changeDecks.handle(auth, lobby, action, config);
    case "ChangeHouseRule":
      return changeHouseRule.handle(auth, lobby, action, config);
  }
};
