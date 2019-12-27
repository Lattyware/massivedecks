import wu from "wu";
import * as decks from "../games/cards/decks";
import * as source from "../games/cards/source";
import * as sources from "../games/cards/sources";
import * as game from "../games/game";
import { Game } from "../games/game";
import { Lobby } from "../lobby";
import { Change } from "../lobby/change";
import { GameCode } from "../lobby/game-code";
import { ServerState } from "../server-state";
import * as task from "../task";

export class StartGame extends task.TaskBase<decks.Templates[]> {
  private readonly decks: Iterable<source.External>;

  public constructor(gameCode: GameCode, decks: Iterable<source.External>) {
    super(gameCode);
    this.decks = decks;
  }

  protected async begin(server: ServerState): Promise<decks.Templates[]> {
    return Promise.all(
      wu(this.decks).map(deck =>
        sources.resolver(server.cache, deck).templates()
      )
    );
  }

  protected resolve(
    lobby: Lobby,
    work: decks.Templates[],
    server: ServerState
  ): Change {
    if (lobby.game !== undefined) {
      return {};
    }
    const lobbyGame = Game.start(work, lobby.users, lobby.config.rules);

    const atStartOfRound = game.atStartOfRound(server, true, lobbyGame);
    lobby.game = atStartOfRound.game;
    return {
      lobby,
      events: atStartOfRound.events,
      timeouts: atStartOfRound.timeouts
    };
  }

  // This is super unlikely timing-wise, and if it happens, the user just has
  // to click start again. They'll live.
  public static *discover(
    gameCode: GameCode,
    lobby: Lobby
  ): Iterable<StartGame> {}
}
