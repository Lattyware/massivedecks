import jsonPatch from "rfc6902";
import { ReplaceOperation, TestOperation } from "rfc6902/diff";
import jp from "rfc6902/patch";
import { Action } from "../../action";
import { ConfigEditConflictError } from "../../errors/action-execution-error";
import { InvalidActionError } from "../../errors/validation";
import * as event from "../../event";
import * as configured from "../../events/lobby-event/configured";
import * as sources from "../../games/cards/sources";
import * as rules from "../../games/rules";
import { Rules } from "../../games/rules";
import * as houseRules from "../../games/rules/houseRules";
import { HouseRules } from "../../games/rules/houseRules";
import * as rando from "../../games/rules/rando";
import { Rando } from "../../games/rules/rando";
import { Lobby } from "../../lobby";
import * as config from "../../lobby/config";
import { Config } from "../../lobby/config";
import { GameCode } from "../../lobby/game-code";
import { Task } from "../../task";
import { LoadDeckSummary } from "../../task/load-deck-summary";
import { Handler } from "../handler";
import * as validation from "../validation.validator";

/**
 * An action to change the configuration of the lobby.
 */
export type Configure = {
  action: NameType;
  /**
   * The changes to the config as a JSON patch.
   */
  change: jsonPatch.Patch;
};

type NameType = "Configure";
const name: NameType = "Configure";

/**
 * Check if an action is a configure action.
 * @param action The action to check.
 */
export const is = (action: Action): action is Configure =>
  action.action === name;

interface Result<T> {
  result: T;
  events: Iterable<event.Distributor>;
  tasks: Iterable<Task>;
}

function applyRando(
  lobby: Lobby,
  existing: Rando,
  updated?: rando.Public
): Result<Rando> {
  const events = rando.change(lobby, existing, updated);
  return { result: existing, events, tasks: [] };
}

function applyHouseRules(
  lobby: Lobby,
  existing: HouseRules,
  updated: houseRules.Public
): Result<HouseRules> {
  const { result, events, tasks } = applyRando(
    lobby,
    existing.rando,
    updated.rando
  );
  return {
    result: { ...updated, rando: result },
    events,
    tasks
  };
}

function applyRules(
  lobby: Lobby,
  existing: Rules,
  updated: rules.Public
): Result<Rules> {
  const { result, events, tasks } = applyHouseRules(
    lobby,
    existing.houseRules,
    updated.houseRules
  );
  return {
    result: { ...updated, houseRules: result },
    events,
    tasks
  };
}

function apply(
  gameCode: GameCode,
  lobby: Lobby,
  existing: Config,
  updated: config.Public
): Result<Config> {
  const { result, events, tasks } = applyRules(
    lobby,
    existing.rules,
    updated.rules
  );
  const allTasks = [...tasks];
  for (const deck of updated.decks) {
    const resolver = sources.limitedResolver(deck.source);
    const matching = existing.decks.find(ed => resolver.equals(ed.source));
    if (matching === undefined) {
      allTasks.push(new LoadDeckSummary(gameCode, deck.source));
    }
  }
  return {
    result: {
      ...updated,
      version: existing.version + 1,
      rules: result,
      public: updated.public !== undefined ? updated.public : false
    },
    events,
    tasks: allTasks
  };
}

const validate = (operation: jsonPatch.Operation): void => {
  const path = operation.path;
  if (path.startsWith("/decks/")) {
    switch (operation.op) {
      case "add":
        if (
          operation.value.hasOwnProperty("summary") ||
          operation.value.hasOwnProperty("failure")
        ) {
          throw new InvalidActionError("Can't add summaries or failures.");
        }
        break;
      case "remove":
        if (path.endsWith("summary") || path.endsWith("failure")) {
          throw new InvalidActionError("Can't remove summaries or failures.");
        }
        break;
      default:
        throw new InvalidActionError("Illegal action for decks.");
    }
  }
};

const _validateConfig = validation.validate("PublicConfig");

export const handle: Handler<Configure> = (auth, lobby, action) => {
  const version = lobby.config.version;
  for (const op of action.change) {
    validate(op);
  }
  let validated = null;
  const patched = JSON.parse(JSON.stringify(config.censor(lobby.config)));
  for (const error of jsonPatch.applyPatch(patched, action.change)) {
    if (error instanceof jp.TestError) {
      throw new ConfigEditConflictError(action, error.expected, error.actual);
    } else if (error !== null) {
      throw new InvalidActionError(`${error.name}: ${error.message}`);
    }
  }
  validated = _validateConfig(patched);
  const { result, events, tasks } = apply(
    auth.gc,
    lobby,
    lobby.config,
    validated
  );
  lobby.config = result;
  const testVersion: TestOperation = {
    op: "test",
    path: "/version",
    value: version.toString()
  };
  const replaceVersion: ReplaceOperation = {
    op: "replace",
    path: "/version",
    value: lobby.config.version.toString()
  };
  const patch = [testVersion, ...action.change, replaceVersion];
  return {
    lobby,
    events: [event.targetAll(configured.of(patch)), ...events],
    tasks: tasks
  };
};
