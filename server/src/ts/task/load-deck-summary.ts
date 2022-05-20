import Rfc6902 from "rfc6902";
import type { ReplaceOperation, TestOperation } from "rfc6902/diff.js";

import {
  SourceNotFoundError,
  SourceServiceError,
} from "../errors/action-execution-error.js";
import * as Event from "../event.js";
import * as Configured from "../events/lobby-event/configured.js";
import type * as Source from "../games/cards/source.js";
import type { Lobby } from "../lobby.js";
import type { Change } from "../lobby/change.js";
import * as Config from "../lobby/config.js";
import type { GameCode } from "../lobby/game-code.js";
import type { ServerState } from "../server-state.js";
import * as Task from "../task.js";

export class LoadDeckSummary extends Task.TaskBase<Source.Summary> {
  public readonly source: Source.External;

  public constructor(gameCode: GameCode, source: Source.External) {
    super(gameCode);
    this.source = source;
  }

  protected async begin(server: ServerState): Promise<Source.Summary> {
    const loaded = await server.sources
      .resolver(server.cache, this.source)
      // We are intentionally ensuring the templates get cached here in advance,
      // but don't actually need to do anything with them at this point.
      .summaryAndTemplates();
    return loaded.summary;
  }

  private resolveInternal(
    lobby: Lobby,
    modify: (source: Config.ConfiguredSource) => void,
    server: ServerState,
  ): Change {
    const lobbyConfig = lobby.config;
    const oldConfig = JSON.parse(JSON.stringify(Config.censor(lobby.config)));
    const decks = lobbyConfig.decks;
    const resolver = server.sources.limitedResolver(this.source);
    const target = decks.find((deck) => resolver.equals(deck.source));
    if (target !== undefined) {
      modify(target);
      const oldVersion = lobbyConfig.version;
      const patch = Rfc6902.createPatch(oldConfig, Config.censor(lobbyConfig));
      lobbyConfig.version += 1;
      const testVersion: TestOperation = {
        op: "test",
        path: "/version",
        value: oldVersion.toString(),
      };
      const replaceVersion: ReplaceOperation = {
        op: "replace",
        path: "/version",
        value: lobbyConfig.version.toString(),
      };
      return {
        lobby,
        events: [
          Event.targetAll(
            Configured.of([testVersion, ...patch, replaceVersion]),
          ),
        ],
      };
    } else {
      return {};
    }
  }

  protected resolve(
    lobby: Lobby,
    work: Source.Summary,
    server: ServerState,
  ): Change {
    return this.resolveInternal(
      lobby,
      (summarised) => {
        if (!Config.isFailed(summarised)) {
          summarised.summary = { ...work, tag: undefined };
        }
      },
      server,
    );
  }

  protected override resolveError(
    lobby: Lobby,
    error: Error,
    server: ServerState,
  ): Change {
    let reason: Config.FailReason;
    if (error instanceof SourceNotFoundError) {
      reason = "NotFound";
    } else if (error instanceof SourceServiceError) {
      reason = "SourceFailure";
    } else {
      throw error;
    }
    return this.resolveInternal(
      lobby,
      (failed) => {
        if (!Object.hasOwn(failed, "summary")) {
          (failed as Config.FailedSource).failure = reason;
        }
      },
      server,
    );
  }

  public static *discover(
    gameCode: GameCode,
    lobby: Lobby,
  ): Iterable<LoadDeckSummary> {
    for (const deck of lobby.config.decks) {
      if (!Config.isFailed(deck) && deck.summary === undefined) {
        yield new LoadDeckSummary(gameCode, deck.source);
      }
    }
  }
}
