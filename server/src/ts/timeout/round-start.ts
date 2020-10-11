import * as Event from "../event";
import * as GameEnded from "../events/game-event/game-ended";
import * as Lobby from "../lobby";
import * as Timeout from "../timeout";

/**
 * Indicates that the round should start if it is still appropriate to do so.
 */
export interface RoundStart {
  timeout: "RoundStart";
}

export const of = (): RoundStart => ({
  timeout: "RoundStart",
});

export const handle: Timeout.Handler<RoundStart> = (
  server,
  timeout,
  gameCode,
  inLobby
) => {
  if (Lobby.hasActiveGame(inLobby)) {
    const lobbyGame = inLobby.game;
    const gameRound = lobbyGame.round;

    const events = [];
    const scoreLimit = lobbyGame.rules.scoreLimit;
    if (scoreLimit !== undefined) {
      let max = scoreLimit;
      const winners = [];
      for (const [id, player] of Object.entries(lobbyGame.players)) {
        if (player.score > max) {
          max = player.score;
          winners.length = 0;
        }
        if (player.score === max) {
          winners.push(id);
        }
      }
      if (winners.length > 0) {
        if (
          lobbyGame.rules.houseRules.happyEnding !== undefined &&
          !lobbyGame.rules.houseRules.happyEnding.inFinalRound
        ) {
          lobbyGame.rules.houseRules.happyEnding.inFinalRound = true;
        } else {
          lobbyGame.winner = winners;
          events.push(Event.targetAll(GameEnded.of(...winners)));

          return {
            inLobby,
            events,
          };
        }
      }
    }

    if (gameRound.stage === "Complete") {
      const result = lobbyGame.startNewRound(server, inLobby);
      return {
        lobby: inLobby,
        ...result,
      };
    }
  }
  return {};
};
