import { Action } from "../../action";
import { InvalidActionError } from "../../errors/validation";
import { User } from "../../user";
import * as user from "../../user";
import * as Lobby from "../../lobby";
import { dealWithLostPlayer } from "../game-action/set-presence";
import { Handler } from "../handler";

/**
 * A privileged user asks to set a given player as away.
 */
export interface SetPlayerAway {
  action: "SetPlayerAway";
  player: user.Id;
}

type NameType = "SetPlayerAway";
const name: NameType = "SetPlayerAway";

export const is = (action: Action): action is SetPlayerAway =>
  action.action === name;

export const handle: Handler<SetPlayerAway> = (auth, lobby, action, server) => {
  const game = lobby.game;
  if (game === undefined) {
    throw new InvalidActionError("Must be in a game.");
  }

  const user = lobby.users.get(action.player) as User;
  if (user.control === "Computer") {
    throw new InvalidActionError("Can't do this with AIs.");
  }

  const playerId = action.player;
  const player = game.players.get(playerId);
  if (player === undefined) {
    throw new InvalidActionError("Must be a player to set away.");
  }

  if (player.presence !== "Away") {
    return dealWithLostPlayer(server, lobby as Lobby.WithActiveGame, playerId);
  } else {
    return {};
  }
};
