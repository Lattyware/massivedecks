import { InvalidActionError } from "../../errors/validation";
import * as Event from "../../event";
import * as PlayerPresenceChanged from "../../events/game-event/player-presence-changed";
import * as Player from "../../games/player";
import * as Lobby from "../../lobby";
import { ConstrainedChange } from "../../lobby/change";
import { ServerState } from "../../server-state";
import * as User from "../../user";
import * as Util from "../../util";
import * as GameAction from "../game-action";
import * as Handler from "../handler";
import * as Actions from "./../actions";

/**
 * A player asks to set themself as away.
 */
export interface SetPresence {
  action: "SetPresence";
  presence: Player.Presence;
}

export const dealWithLostPlayer = (
  server: ServerState,
  lobby: Lobby.WithActiveGame,
  playerId: User.Id
): ConstrainedChange<Lobby.WithActiveGame> => {
  const game = lobby.game;

  const player = game.players[playerId];
  if (player === undefined) {
    throw new InvalidActionError("Must be a player.");
  }
  player.presence = "Away";

  const invalidateRoundResult =
    game.round.czar === playerId ? game.startNewRound(server, lobby) : {};

  const removeFromRoundResult = game.round.players.has(playerId)
    ? game.removeFromRound(playerId, server)
    : {};

  return {
    lobby,
    events: [
      Event.targetAll(PlayerPresenceChanged.away(playerId)),
      ...(invalidateRoundResult.events !== undefined
        ? invalidateRoundResult.events
        : []),
    ],
    timeouts: [
      ...(invalidateRoundResult.timeouts !== undefined
        ? invalidateRoundResult.timeouts
        : []),
      ...(removeFromRoundResult.timeouts !== undefined
        ? removeFromRoundResult.timeouts
        : []),
    ],
  };
};

class SetPresenceActions extends Actions.Implementation<
  GameAction.GameAction,
  SetPresence,
  "SetPresence",
  Lobby.WithActiveGame
> {
  protected readonly name = "SetPresence";

  protected handle: Handler.Custom<SetPresence, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action,
    server
  ) => {
    const game = lobby.game;
    const playerId = auth.uid;
    const player = game.players[playerId];
    if (player === undefined) {
      throw new InvalidActionError("Must be a player to set away.");
    }

    if (player.presence !== action.presence) {
      player.presence = action.presence;

      if (player.presence === "Away") {
        return dealWithLostPlayer(server, lobby, playerId);
      } else if (player.presence === "Active") {
        const unpause = game.paused ? game.startNewRound(server, lobby) : {};

        return {
          lobby,
          events: [
            Event.targetAll(PlayerPresenceChanged.back(playerId)),
            ...(unpause.events !== undefined ? unpause.events : []),
          ],
          timeouts: unpause.timeouts,
        };
      } else {
        Util.assertNever(player.presence);
      }
    } else {
      return {};
    }
  };
}

export const actions = new SetPresenceActions();
