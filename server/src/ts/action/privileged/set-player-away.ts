import * as Actions from "./../actions";
import { InvalidActionError } from "../../errors/validation";
import * as User from "../../user";
import * as Lobby from "../../lobby";
import * as SetPresence from "../game-action/set-presence";
import * as Handler from "../handler";
import { Privileged } from "../privileged";

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
    server
  ) => {
    const game = lobby.game;
    if (game === undefined) {
      throw new InvalidActionError("Must be in a game.");
    }

    const user = lobby.users[action.player];
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
        playerId
      );
    } else {
      return {};
    }
  };
}

export const actions = new SetPlayerAwayActions();
