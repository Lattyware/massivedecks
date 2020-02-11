import { Action } from "../action";
import { UnprivilegedError } from "../errors/action-execution-error";
import * as Lobby from "../lobby";
import * as Token from "../user/token";
import * as Actions from "./actions";
import * as Configure from "./privileged/configure";
import * as EndGame from "./privileged/end-game";
import * as Kick from "./privileged/kick";
import * as SetPlayerAway from "./privileged/set-player-away";
import * as SetPrivilege from "./privileged/set-privilege";
import * as StartGame from "./privileged/start-game";

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
      EndGame.actions
    );
  }

  public limit(
    auth: Token.Claims,
    lobby: Lobby.Lobby,
    action: Privileged
  ): lobby is Lobby.WithActiveGame {
    const user = lobby.users[auth.uid];
    if (user === undefined || user.privilege !== "Privileged") {
      throw new UnprivilegedError(action);
    }
    return true;
  }
}

export const actions = new PrivilegedActions();
