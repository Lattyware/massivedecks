import { InvalidActionError } from "../../errors/validation.js";
import * as Event from "../../event.js";
import * as PresenceChanged from "../../events/lobby-event/presence-changed.js";
import type * as Lobby from "../../lobby.js";
import type { Change } from "../../lobby/change.js";
import type { ServerState } from "../../server-state.js";
import type * as Timeout from "../../timeout.js";
import type * as User from "../../user.js";
import type * as Handler from "../handler.js";
import type { Privileged } from "../privileged.js";
import * as Actions from "./../actions.js";

/**
 * A player asks to leave the game.
 */
export interface Kick {
  action: "Kick";
  user: User.Id;
}

export const removeUser = (
  userId: User.Id,
  lobby: Lobby.Lobby,
  server: ServerState,
  leaveReason: PresenceChanged.LeaveReason,
): Change => {
  const user = lobby.users[userId] as User.User;
  user.presence = "Left";

  if (user.control === "Computer") {
    throw new InvalidActionError("Can't do this with AIs.");
  }

  const allEvents = [
    Event.targetAllAndPotentiallyClose(
      PresenceChanged.left(userId, leaveReason),
      (id) => id === userId,
    ),
  ];
  const allTimeouts: Timeout.After[] = [];

  const addResult = (eventsAndTimeouts: {
    events?: Iterable<Event.Distributor>;
    timeouts?: Iterable<Timeout.After>;
  }): void => {
    const { events, timeouts } = eventsAndTimeouts;
    if (events) {
      allEvents.push(...events);
    }
    if (timeouts) {
      allTimeouts.push(...timeouts);
    }
  };

  const game = lobby.game;
  if (game !== undefined) {
    const player = game.players[userId];
    if (player !== undefined) {
      addResult(
        game.round.czar === userId ? game.startNewRound(server, lobby) : {},
      );

      addResult(
        game.round.players.has(userId)
          ? game.removeFromRound(userId, server)
          : {},
      );
    }
  }

  return {
    lobby,
    events: allEvents,
    timeouts: allTimeouts,
  };
};

class KickActions extends Actions.Implementation<
  Privileged,
  Kick,
  "Kick",
  Lobby.Lobby
> {
  protected readonly name = "Kick";

  protected handle: Handler.Custom<Kick, Lobby.Lobby> = (
    auth,
    lobby,
    action,
    server,
  ) => removeUser(action.user, lobby, server, "Kicked");
}

export const actions = new KickActions();
