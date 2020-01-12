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
      const result = lobbyGame.startNewRound(server, inLobby);
      return {
        inLobby,
        ...result
      };
    }
  }
  return {};
};
