import jsonPatch from "rfc6902";
import * as event from "../event";
import * as configured from "../events/lobby-event/configured";
import * as deckSource from "../games/cards/source";
import * as sources from "../games/cards/sources";
import {
  SourceNotFoundError,
  SourceServiceError
} from "../games/cards/sources";
import { Lobby } from "../lobby";
import { Change } from "../lobby/change";
import * as config from "../lobby/config";
import { GameCode } from "../lobby/game-code";
import { ServerState } from "../server-state";
import * as task from "../task";

export class LoadDeckSummary extends task.TaskBase<deckSource.Summary> {
  private readonly source: deckSource.External;

  public constructor(gameCode: GameCode, source: deckSource.External) {
    super(gameCode);
    this.source = source;
  }

  protected async begin(server: ServerState): Promise<deckSource.Summary> {
    const loaded = await sources
      .resolver(server.cache, this.source)
      // We are intentionally ensuring the templates get cached here in advance,
      // but don't actually need to do anything with them at this point.
      .summaryAndTemplates();
    return loaded.summary;
  }

  private resolveInternal(
    lobby: Lobby,
    modify: (source: config.ConfiguredSource) => void
  ): Change {
    const lobbyConfig = lobby.config;
    const oldConfig = JSON.parse(JSON.stringify(config.censor(lobby.config)));
    const decks = lobbyConfig.decks;
    const resolver = sources.limitedResolver(this.source);
    const target = decks.find(deck => resolver.equals(deck.source));
    if (target !== undefined) {
      modify(target);
      lobbyConfig.version += 1;
      const patch = jsonPatch.createPatch(
        oldConfig,
        config.censor(lobbyConfig)
      );
      return {
        lobby,
        events: [event.targetAll(configured.of(patch))]
      };
    } else {
      return {};
    }
  }

  protected resolve(lobby: Lobby, work: deckSource.Summary): Change {
    return this.resolveInternal(lobby, summarised => {
      if (!config.isFailed(summarised)) {
        summarised.summary = { ...work, tag: undefined };
      }
    });
  }

  protected resolveError(lobby: Lobby, error: Error): Change {
    let reason: config.FailReason;
    if (error instanceof SourceNotFoundError) {
      reason = "NotFound";
    } else if (error instanceof SourceServiceError) {
      reason = "SourceFailure";
    } else {
      throw error;
    }
    return this.resolveInternal(lobby, failed => {
      if (!failed.hasOwnProperty("summary")) {
        (failed as config.FailedSource).failure = reason;
      }
    });
  }

  public static *discover(
    gameCode: GameCode,
    lobby: Lobby
  ): Iterable<LoadDeckSummary> {
    for (const deck of lobby.config.decks) {
      if (!config.isFailed(deck) && deck.summary === undefined) {
        yield new LoadDeckSummary(gameCode, deck.source);
      }
    }
  }
}
