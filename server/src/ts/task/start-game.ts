import wu from "wu";

import type * as Decks from "../games/cards/decks.js";
import type * as Source from "../games/cards/source.js";
import { Game } from "../games/game.js";
import type { Lobby } from "../lobby.js";
import type { Change } from "../lobby/change.js";
import type { GameCode } from "../lobby/game-code.js";
import type { ServerState } from "../server-state.js";
import * as Task from "../task.js";

export class StartGame extends Task.TaskBase<Decks.Templates[]> {
  private readonly decks: Iterable<Source.External>;

  public constructor(gameCode: GameCode, decks: Iterable<Source.External>) {
    super(gameCode);
    this.decks = decks;
  }

  protected async begin(server: ServerState): Promise<Decks.Templates[]> {
    return Promise.all(
      wu(this.decks).map((deck) =>
        server.sources.resolver(server.cache, deck).templates(),
      ),
    );
  }

  protected resolve(
    lobby: Lobby,
    work: Decks.Templates[],
    server: ServerState,
  ): Change {
    if (lobby.game !== undefined && lobby.game.winner === undefined) {
      // If we have an existing game that isn't finished, we don't try and
      // start a new one.
      return {};
    }

    const lobbyGame = Game.start(work, lobby.users, lobby.config.rules);

    const { events, timeouts } = lobbyGame.startRound(
      server,
      true,
      lobbyGame.round,
    );

    lobby.game = lobbyGame;

    return {
      lobby,
      events,
      timeouts,
    };
  }

  // This is super unlikely timing-wise, and if it happens, the user just has
  // to click start again. They'll live.
  public static *discover(
    _gameCode: GameCode,
    _lobby: Lobby,
    // eslint-disable-next-line @typescript-eslint/no-empty-function
  ): Iterable<StartGame> {}
}
