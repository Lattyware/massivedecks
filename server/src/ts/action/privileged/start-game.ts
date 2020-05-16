import * as Actions from "./../actions";
import * as Lobby from "../../lobby";
import { StartGame as StartGameTask } from "../../task/start-game";
import * as Handler from "../handler";
import { Privileged } from "../privileged";

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
          lobby.config.decks.map((s) => s.source)
        ),
      ],
    });
}

export const actions = new StartGameActions();
