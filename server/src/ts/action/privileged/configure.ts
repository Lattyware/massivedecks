import Rfc6902 from "rfc6902";
import type { ReplaceOperation, TestOperation } from "rfc6902/diff.js";
import Rfc6902Patch from "rfc6902/patch.js";

import { ConfigEditConflictError } from "../../errors/action-execution-error.js";
import { InvalidActionError } from "../../errors/validation.js";
import * as Event from "../../event.js";
import * as Configured from "../../events/lobby-event/configured.js";
import type * as Rules from "../../games/rules.js";
import type * as HouseRules from "../../games/rules/house-rules.js";
import * as Rando from "../../games/rules/rando.js";
import type * as Lobby from "../../lobby.js";
import * as Config from "../../lobby/config.js";
import type { GameCode } from "../../lobby/game-code.js";
import type { ServerState } from "../../server-state.js";
import type { Task } from "../../task.js";
import { LoadDeckSummary } from "../../task/load-deck-summary.js";
import type * as Handler from "../handler.js";
import type { Privileged } from "../privileged.js";
import * as Validation from "../validation.validator.js";
import * as Actions from "./../actions.js";

/**
 * An action to change the configuration of the lobby.
 */
export interface Configure {
  action: "Configure";
  /**
   * The changes to the config as a JSON patch.
   */
  change: Rfc6902.Patch;
}

interface Result<T> {
  result: T;
  events: Iterable<Event.Distributor>;
  tasks: Iterable<Task>;
}

function applyRando(
  lobby: Lobby.Lobby,
  existing: Rando.Rando,
  updated?: Rando.Public,
): Result<Rando.Rando> {
  const events = Rando.change(lobby, existing, updated);
  return { result: existing, events, tasks: [] };
}

function applyHouseRules(
  lobby: Lobby.Lobby,
  existing: HouseRules.HouseRules,
  updated: HouseRules.Public,
): Result<HouseRules.HouseRules> {
  const { result, events, tasks } = applyRando(
    lobby,
    existing.rando,
    updated.rando,
  );
  return {
    result: { ...updated, rando: result },
    events,
    tasks,
  };
}

function applyRules(
  lobby: Lobby.Lobby,
  existing: Rules.Rules,
  updated: Rules.Public,
): Result<Rules.Rules> {
  const { result, events, tasks } = applyHouseRules(
    lobby,
    existing.houseRules,
    updated.houseRules,
  );
  return {
    result: { ...updated, houseRules: result },
    events,
    tasks,
  };
}

function apply(
  server: ServerState,
  gameCode: GameCode,
  lobby: Lobby.Lobby,
  existing: Config.Config,
  updated: Config.Public,
): Result<Config.Config> {
  const { result, events, tasks } = applyRules(
    lobby,
    existing.rules,
    updated.rules,
  );
  const allTasks = [...tasks];
  for (const deck of updated.decks) {
    const resolver = server.sources.limitedResolver(deck.source);
    const matching = existing.decks.find((ed) => resolver.equals(ed.source));
    if (matching === undefined) {
      allTasks.push(new LoadDeckSummary(gameCode, deck.source));
    }
  }
  return {
    result: {
      ...updated,
      version: existing.version + 1,
      rules: result,
      public: updated.public !== undefined ? updated.public : false,
      audienceMode:
        updated.audienceMode !== undefined ? updated.audienceMode : false,
    },
    events,
    tasks: allTasks,
  };
}

const validate = (operation: Rfc6902.Operation): void => {
  const path = operation.path;
  if (path.startsWith("/decks/")) {
    switch (operation.op) {
      case "add":
        if (
          Object.hasOwn(operation.value, "summary") ||
          Object.hasOwn(operation.value, "failure")
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

const _validateConfig = Validation.validate("PublicConfig");

class ConfigureActions extends Actions.Implementation<
  Privileged,
  Configure,
  "Configure",
  Lobby.Lobby
> {
  protected readonly name = "Configure";

  protected handle: Handler.Custom<Configure, Lobby.Lobby> = (
    auth,
    lobby,
    action,
    server,
  ) => {
    const version = lobby.config.version;
    for (const op of action.change) {
      validate(op);
    }
    let validated = null;
    const patched = JSON.parse(JSON.stringify(Config.censor(lobby.config)));
    for (const error of Rfc6902.applyPatch(patched, action.change)) {
      if (error instanceof Rfc6902Patch.TestError) {
        throw new ConfigEditConflictError(action, error.expected, error.actual);
      } else if (error !== null) {
        throw new InvalidActionError(`${error.name}: ${error.message}`);
      }
    }
    try {
      validated = _validateConfig(patched);
    } catch (e) {
      const error = e as Error;
      throw new InvalidActionError(`${error.name}: ${error.message}`);
    }
    const { result, events, tasks } = apply(
      server,
      auth.gc,
      lobby,
      lobby.config,
      validated,
    );
    lobby.config = result;
    const testVersion: TestOperation = {
      op: "test",
      path: "/version",
      value: version.toString(),
    };
    const replaceVersion: ReplaceOperation = {
      op: "replace",
      path: "/version",
      value: lobby.config.version.toString(),
    };
    const patch = [testVersion, ...action.change, replaceVersion];
    return {
      lobby,
      events: [Event.targetAll(Configured.of(patch)), ...events],
      tasks: tasks,
    };
  };
}

export const actions = new ConfigureActions();
