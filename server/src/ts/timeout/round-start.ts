import wu from "wu";
import * as event from "../event";
import * as roundStarted from "../events/game-event/round-started";
import * as game from "../games/game";
import * as timeout from "../timeout";
import * as card from "../games/cards/card";
import * as player from "../games/player";

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
  lobby
) => {
  const lobbyGame = lobby.game;
  if (lobbyGame !== undefined) {
    const gameRound = lobbyGame.round;
    if (gameRound.stage === "Complete") {
      const czar = game.nextCzar(lobbyGame);
      const [call] = lobbyGame.decks.calls.replace(gameRound.call);
      const slotCount = card.slotCount(call);
      const roundId = gameRound.id + 1;
      const playersInRound = new Set(
        wu(lobbyGame.playerOrder).filter(id => id !== czar)
      );
      lobbyGame.decks.responses.discard(
        gameRound.plays.flatMap(play => play.play)
      );
      lobbyGame.round = {
        stage: "Playing",
        id: roundId,
        czar: czar,
        players: playersInRound,
        call: call,
        plays: []
      };
      const playersArray = Array.from(playersInRound);
      const baseEvent = roundStarted.of(roundId, czar, playersArray, call);

      let events;
      if (
        slotCount > 2 ||
        (slotCount === 2 &&
          lobbyGame.rules.houseRules.packingHeat !== undefined)
      ) {
        const responseDeck = lobbyGame.decks.responses;
        const drawnByPlayer = new Map();
        for (const [id, playerState] of lobbyGame.players) {
          if (player.role(lobbyGame, id) === "Player") {
            const drawn = responseDeck.draw(slotCount - 1);
            drawnByPlayer.set(id, { drawn });
            playerState.hand.push(...drawn);
          }
        }
        events = [event.additionally(baseEvent, drawnByPlayer)];
      } else {
        events = [event.targetAll(baseEvent)];
      }
      return { lobby, events };
    }
  }
  return {};
};
