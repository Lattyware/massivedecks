import * as event from "../event";
import * as decksChanged from "../events/lobby-event/configured/decks-changed";
import * as deckSource from "../games/cards/source";
import * as sources from "../games/cards/sources";
import { Lobby } from "../lobby";
import { Change } from "../lobby/change";
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
    // We are intentionally ensuring the templates get cached here in advance,
    // but don't actually need to do anything with them at this point.
    return sources.resolver(server.cache, this.source).summaryAndTemplates()
      .summary;
  }

  protected resolve(lobby: Lobby, work: deckSource.Summary): Change {
    const config = lobby.config;
    const resolver = sources.limitedResolver(this.source);
    const summarised = config.decks.find(deck => resolver.equals(deck.source));
    if (summarised !== undefined) {
      summarised.summary = work;
      config.version += 1;
      return {
        lobby,
        events: [
          event.targetAll(
            decksChanged.of(
              this.source,
              { change: "Load", summary: work },
              config.version
            )
          )
        ]
      };
    } else {
      return {};
    }
  }

  public static *discover(
    gameCode: GameCode,
    lobby: Lobby
  ): Iterable<LoadDeckSummary> {
    const config = lobby.config;
    for (const deck of config.decks) {
      if (deck.summary === undefined) {
        yield new LoadDeckSummary(gameCode, deck.source);
      }
    }
  }
}
