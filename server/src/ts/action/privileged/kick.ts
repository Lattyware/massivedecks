import { Action } from "../../action";
import { InvalidActionError } from "../../errors/validation";
import * as event from "../../event";
import * as presenceChanged from "../../events/lobby-event/presence-changed";
import { Lobby } from "../../lobby";
import { Change } from "../../lobby/change";
import { ServerState } from "../../server-state";
import { default as timeout, TimeoutAfter } from "../../timeout";
import { User } from "../../user";
import { Handler } from "../handler";
import * as user from "../../user";

/**
 * A player asks to leave the game.
 */
export interface Kick {
  action: "Kick";
  user: user.Id;
}

type NameType = "Kick";
const name: NameType = "Kick";

export const is = (action: Action): action is Kick => action.action === name;

export const removeUser = (
  userId: user.Id,
  lobby: Lobby,
  server: ServerState,
  leaveReason: presenceChanged.LeaveReason
): Change => {
  const user = lobby.users.get(userId) as User;
  user.presence = "Left";

  if (user.control === "Computer") {
    throw new InvalidActionError("Can't do this with AIs.");
  }

  const allEvents = [
    event.targetAllAndPotentiallyClose(
      presenceChanged.left(userId, leaveReason),
      id => id === userId
    )
  ];
  const allTimeouts: TimeoutAfter[] = [];

  const addResult = (eventsAndTimeouts: {
    events?: Iterable<event.Distributor>;
    timeouts?: Iterable<timeout.TimeoutAfter>;
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
    const player = game.players.get(userId);
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
    events: allEvents,
    timeouts: allTimeouts
  };
};

export const handle: Handler<Kick> = (auth, lobby, action, server) =>
  removeUser(action.user, lobby, server, "Kicked");
