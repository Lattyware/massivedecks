import wu from "wu";
import * as Decks from "../games/cards/decks";
import * as Source from "../games/cards/source";
import { Game } from "../games/game";
import { Lobby } from "../lobby";
import { Change } from "../lobby/change";
import { GameCode } from "../lobby/game-code";
import { ServerState } from "../server-state";
import * as Task from "../task";

export class StartGame extends Task.TaskBase<Decks.Templates[]> {
  private readonly decks: Iterable<Source.External>;

  public constructor(gameCode: GameCode, decks: Iterable<Source.External>) {
    super(gameCode);
    this.decks = decks;
  }

  protected async begin(server: ServerState): Promise<Decks.Templates[]> {
    return Promise.all(
      wu(this.decks).map((deck) =>
        server.sources.resolver(server.cache, deck).templates()
      )
    );
  }

  protected resolve(
    lobby: Lobby,
    work: Decks.Templates[],
    server: ServerState
  ): Change {
    if (lobby.game !== undefined && lobby.game.winner === undefined) {
      // If we have an existing game that isn't finished, we don't try and
      // start a new one.
      return {};
    }
    const lobbyGame = Game.start(work, lobby.users, lobby.config.rules);

    const atStartOfRound = Game.atStartOfRound(server, true, lobbyGame);
    lobby.game = atStartOfRound.game;
    return {
      lobby,
      events: atStartOfRound.events,
      timeouts: atStartOfRound.timeouts,
    };
  }

  // This is super unlikely timing-wise, and if it happens, the user just has
  // to click start again. They'll live.
  public static *discover(
    gameCode: GameCode,
    lobby: Lobby
    // eslint-disable-next-line @typescript-eslint/no-empty-function
  ): Iterable<StartGame> {}
}
