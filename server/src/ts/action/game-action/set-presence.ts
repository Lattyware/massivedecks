import { Action } from "../../action";
import { InvalidActionError } from "../../errors/validation";
import * as event from "../../event";
import * as playerPresenceChanged from "../../events/game-event/player-presence-changed";
import * as player from "../../games/player";
import * as Lobby from "../../lobby";
import { ConstrainedChange } from "../../lobby/change";
import { ServerState } from "../../server-state";
import * as user from "../../user";
import * as util from "../../util";
import * as gameAction from "../game-action";

/**
 * A player asks to set themself as away.
 */
export interface SetPresence {
  action: "SetPresence";
  presence: player.Presence;
}

type NameType = "SetPresence";
const name: NameType = "SetPresence";

export const is = (action: Action): action is SetPresence =>
  action.action === name;

export const dealWithLostPlayer = (
  server: ServerState,
  lobby: Lobby.WithActiveGame,
  playerId: user.Id
): ConstrainedChange<Lobby.WithActiveGame> => {
  const game = lobby.game;

  const player = game.players.get(playerId);
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
      event.targetAll(playerPresenceChanged.away(playerId)),
      ...(invalidateRoundResult.events !== undefined
        ? invalidateRoundResult.events
        : [])
    ],
    timeouts: [
      ...(invalidateRoundResult.timeouts !== undefined
        ? invalidateRoundResult.timeouts
        : []),
      ...(removeFromRoundResult.timeouts !== undefined
        ? removeFromRoundResult.timeouts
        : [])
    ]
  };
};

export const handle: gameAction.Handler<SetPresence> = (
  auth,
  lobby,
  action,
  server
) => {
  const game = lobby.game;
  const playerId = auth.uid;
  const player = game.players.get(playerId);
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
          event.targetAll(playerPresenceChanged.back(playerId)),
          ...(unpause.events !== undefined ? unpause.events : [])
        ],
        timeouts: unpause.timeouts
      };
    } else {
      util.assertNever(player.presence);
    }
  } else {
    return {};
  }
};
