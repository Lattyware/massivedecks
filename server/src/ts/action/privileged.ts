import type { Action } from "../action.js";
import { UnprivilegedError } from "../errors/action-execution-error.js";
import type * as Lobby from "../lobby.js";
import type * as Token from "../user/token.js";
import * as Actions from "./actions.js";
import * as Configure from "./privileged/configure.js";
import * as EndGame from "./privileged/end-game.js";
import * as Kick from "./privileged/kick.js";
import * as SetPlayerAway from "./privileged/set-player-away.js";
import * as SetPrivilege from "./privileged/set-privilege.js";
import * as StartGame from "./privileged/start-game.js";

/**
 * An action only a privileged user can perform.
 */
export type Privileged =
  | Configure.Configure
  | StartGame.StartGame
  | SetPlayerAway.SetPlayerAway
  | SetPrivilege.SetPrivilege
  | Kick.Kick
  | EndGame.EndGame;

class PrivilegedActions extends Actions.Group<
  Action,
  Privileged,
  Lobby.Lobby,
  Lobby.Lobby
> {
  constructor() {
    super(
      Configure.actions,
      StartGame.actions,
      SetPlayerAway.actions,
      SetPrivilege.actions,
      Kick.actions,
      EndGame.actions,
    );
  }

  public limit(
    auth: Token.Claims,
    lobby: Lobby.Lobby,
    action: Privileged,
  ): lobby is Lobby.WithActiveGame {
    const user = lobby.users[auth.uid];
    if (user === undefined || user.privilege !== "Privileged") {
      throw new UnprivilegedError(action);
    }
    return true;
  }
}

export const actions = new PrivilegedActions();
