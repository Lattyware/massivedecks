import Rfc6902 from "rfc6902";
import * as Event from "../event";
import * as Configured from "../events/lobby-event/configured";
import * as Source from "../games/cards/source";
import { Lobby } from "../lobby";
import { Change } from "../lobby/change";
import * as Config from "../lobby/config";
import { GameCode } from "../lobby/game-code";
import { ServerState } from "../server-state";
import * as Task from "../task";
import {
  SourceNotFoundError,
  SourceServiceError,
} from "../errors/action-execution-error";
import { ReplaceOperation, TestOperation } from "rfc6902/diff";

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
    server: ServerState
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
            Configured.of([testVersion, ...patch, replaceVersion])
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
    server: ServerState
  ): Change {
    return this.resolveInternal(
      lobby,
      (summarised) => {
        if (!Config.isFailed(summarised)) {
          summarised.summary = { ...work, tag: undefined };
        }
      },
      server
    );
  }

  protected resolveError(
    lobby: Lobby,
    error: Error,
    server: ServerState
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
        if (!failed.hasOwnProperty("summary")) {
          (failed as Config.FailedSource).failure = reason;
        }
      },
      server
    );
  }

  public static *discover(
    gameCode: GameCode,
    lobby: Lobby
  ): Iterable<LoadDeckSummary> {
    for (const deck of lobby.config.decks) {
      if (!Config.isFailed(deck) && deck.summary === undefined) {
        yield new LoadDeckSummary(gameCode, deck.source);
      }
    }
  }
}
