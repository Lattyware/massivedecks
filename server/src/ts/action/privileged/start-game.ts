import type * as Lobby from "../../lobby.js";
import { StartGame as StartGameTask } from "../../task/start-game.js";
import type * as Handler from "../handler.js";
import type { Privileged } from "../privileged.js";
import * as Actions from "./../actions.js";

/**
 * Start a game in the lobby if possible.
 */
export interface StartGame {
  action: "StartGame";
}

class StartGameActions extends Actions.Implementation<
  Privileged,
  StartGame,
  "StartGame",
  Lobby.Lobby
> {
  protected readonly name = "StartGame";

  protected handle: Handler.Custom<StartGame, Lobby.Lobby> = (auth, lobby) =>
    // We do validation in the task.
    ({
      tasks: [
        new StartGameTask(
          auth.gc,
          lobby.config.decks.map((s) => s.source),
        ),
      ],
    });
}

export const actions = new StartGameActions();
