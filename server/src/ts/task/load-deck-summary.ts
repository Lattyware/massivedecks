import Rfc6902 from "rfc6902";
import * as Event from "../event";
import * as Configured from "../events/lobby-event/configured";
import * as Source from "../games/cards/source";
import * as Sources from "../games/cards/sources";
import {
  SourceNotFoundError,
  SourceServiceError
} from "../games/cards/sources";
import { Lobby } from "../lobby";
import { Change } from "../lobby/change";
import * as Config from "../lobby/config";
import { GameCode } from "../lobby/game-code";
import { ServerState } from "../server-state";
import * as Task from "../task";

export class LoadDeckSummary extends Task.TaskBase<Source.Summary> {
  private readonly source: Source.External;

  public constructor(gameCode: GameCode, source: Source.External) {
    super(gameCode);
    this.source = source;
  }

  protected async begin(server: ServerState): Promise<Source.Summary> {
    const loaded = await Sources.resolver(server.cache, this.source)
      // We are intentionally ensuring the templates get cached here in advance,
      // but don't actually need to do anything with them at this point.
      .summaryAndTemplates();
    return loaded.summary;
  }

  private resolveInternal(
    lobby: Lobby,
    modify: (source: Config.ConfiguredSource) => void
  ): Change {
    const lobbyConfig = lobby.config;
    const oldConfig = JSON.parse(JSON.stringify(Config.censor(lobby.config)));
    const decks = lobbyConfig.decks;
    const resolver = Sources.limitedResolver(this.source);
    const target = decks.find(deck => resolver.equals(deck.source));
    if (target !== undefined) {
      modify(target);
      lobbyConfig.version += 1;
      const patch = Rfc6902.createPatch(oldConfig, Config.censor(lobbyConfig));
      return {
        lobby,
        events: [Event.targetAll(Configured.of(patch))]
      };
    } else {
      return {};
    }
  }

  protected resolve(lobby: Lobby, work: Source.Summary): Change {
    return this.resolveInternal(lobby, summarised => {
      if (!Config.isFailed(summarised)) {
        summarised.summary = { ...work, tag: undefined };
      }
    });
  }

  protected resolveError(lobby: Lobby, error: Error): Change {
    let reason: Config.FailReason;
    if (error instanceof SourceNotFoundError) {
      reason = "NotFound";
    } else if (error instanceof SourceServiceError) {
      reason = "SourceFailure";
    } else {
      throw error;
    }
    return this.resolveInternal(lobby, failed => {
      if (!failed.hasOwnProperty("summary")) {
        (failed as Config.FailedSource).failure = reason;
      }
    });
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
