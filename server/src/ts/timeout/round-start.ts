import wu from "wu";
import * as game from "../games/game";
import { Game } from "../games/game";
import { Playing } from "../games/game/round";
import * as lobby from "../lobby";
import * as timeout from "../timeout";

/**
 * Indicates that the round should start if it is still appropriate to do so.
 */
export interface RoundStart {
  timeout: "RoundStart";
}

export const of = (): RoundStart => ({
  timeout: "RoundStart"
});

export const handle: timeout.Handler<RoundStart> = (
  server,
  timeout,
  gameCode,
  inLobby
) => {
  if (lobby.hasActiveGame(inLobby)) {
    const lobbyGame = inLobby.game;
    const gameRound = lobbyGame.round;
    if (gameRound.stage === "Complete") {
      const czar = lobbyGame.nextCzar(inLobby.users);
      const [call] = lobbyGame.decks.calls.replace(gameRound.call);
      const roundId = gameRound.id + 1;
      const playersInRound = new Set(
        wu(lobbyGame.playerOrder).filter(id => id !== czar)
      );
      lobbyGame.decks.responses.discard(
        gameRound.plays.flatMap(play => play.play)
      );
      lobbyGame.round = new Playing(roundId, czar, playersInRound, call);
      const updatedGame = lobbyGame as Game & { round: Playing };
      const atStartOfRound = game.atStartOfRound(server, false, updatedGame);
      inLobby.game = atStartOfRound.game;
      return {
        inLobby,
        events: atStartOfRound.events,
        timeouts: atStartOfRound.timeouts
      };
    }
  }
  return {};
};
