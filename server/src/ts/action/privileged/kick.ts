import * as Actions from "./../actions";
import { InvalidActionError } from "../../errors/validation";
import * as Event from "../../event";
import * as PresenceChanged from "../../events/lobby-event/presence-changed";
import * as Lobby from "../../lobby";
import { Change } from "../../lobby/change";
import { ServerState } from "../../server-state";
import * as Timeout from "../../timeout";
import * as User from "../../user";
import * as Handler from "../handler";
import { Privileged } from "../privileged";

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
  leaveReason: PresenceChanged.LeaveReason
): Change => {
  const user = lobby.users[userId];
  user.presence = "Left";

  if (user.control === "Computer") {
    throw new InvalidActionError("Can't do this with AIs.");
  }

  const allEvents = [
    Event.targetAllAndPotentiallyClose(
      PresenceChanged.left(userId, leaveReason),
      (id) => id === userId
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
        game.round.czar === userId ? game.startNewRound(server, lobby) : {}
      );

      addResult(
        game.round.players.has(userId)
          ? game.removeFromRound(userId, server)
          : {}
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
    server
  ) => removeUser(action.user, lobby, server, "Kicked");
}

export const actions = new KickActions();
