import { Action } from "../../action";
import { StartGame as StartGameTask } from "../../task/start-game";
import { Handler } from "../handler";

/**
 * Start a game in the lobby if possible.
 */
export interface StartGame {
  action: NameType;
}

type NameType = "StartGame";
const name: NameType = "StartGame";

export const is = (action: Action): action is StartGame =>
  action.action === name;

export const handle: Handler<StartGame> = (auth, lobby) =>
  // We do validation in the task.
  ({
    tasks: [
      new StartGameTask(
        auth.gc,
        lobby.config.decks.map(s => s.source)
      )
    ]
  });
