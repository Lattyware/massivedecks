import wu from "wu";
import { Game } from "../games/game";
import * as game from "../games/game";
import * as lobby from "../lobby";
import { Playing } from "../games/game/round";
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
      const czar = game.nextCzar(inLobby);
      const [call] = lobbyGame.decks.calls.replace(gameRound.call);
      const roundId = gameRound.id + 1;
      const playersInRound = new Set(
        wu(lobbyGame.playerOrder).filter(id => id !== czar)
      );
      lobbyGame.decks.responses.discard(
        gameRound.plays.flatMap(play => play.play)
      );
      const updatedGame: Game & { round: Playing } = {
        ...lobbyGame,
        round: {
          stage: "Playing",
          id: roundId,
          czar: czar,
          players: playersInRound,
          call: call,
          plays: []
        }
      };
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
