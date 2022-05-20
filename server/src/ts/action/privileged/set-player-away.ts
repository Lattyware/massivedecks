import { InvalidActionError } from "../../errors/validation.js";
import type * as Lobby from "../../lobby.js";
import type * as User from "../../user.js";
import * as SetPresence from "../game-action/set-presence.js";
import type * as Handler from "../handler.js";
import type { Privileged } from "../privileged.js";
import * as Actions from "./../actions.js";

/**
 * A privileged user asks to set a given player as away.
 */
export interface SetPlayerAway {
  action: "SetPlayerAway";
  player: User.Id;
}

class SetPlayerAwayActions extends Actions.Implementation<
  Privileged,
  SetPlayerAway,
  "SetPlayerAway",
  Lobby.Lobby
> {
  protected readonly name = "SetPlayerAway";

  protected handle: Handler.Custom<SetPlayerAway, Lobby.Lobby> = (
    auth,
    lobby,
    action,
    server,
  ) => {
    const game = lobby.game;
    if (game === undefined) {
      throw new InvalidActionError("Must be in a game.");
    }

    const user = lobby.users[action.player] as User.User;
    if (user.control === "Computer") {
      throw new InvalidActionError("Can't do this with AIs.");
    }

    const playerId = action.player;
    const player = game.players[playerId];
    if (player === undefined) {
      throw new InvalidActionError("Must be a player to set away.");
    }

    if (player.presence !== "Away") {
      return SetPresence.dealWithLostPlayer(
        server,
        lobby as Lobby.WithActiveGame,
        playerId,
      );
    } else {
      return {};
    }
  };
}

export const actions = new SetPlayerAwayActions();
