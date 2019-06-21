import wu from "wu";
import * as event from "../event";
import * as roundStarted from "../events/game-event/round-started";
import * as game from "../games/game";
import * as timeout from "../timeout";
import * as card from "../games/cards/card";

/**
 * Indicates that the round should start if it is still appropriate to do so.
 */
export interface RoundStart {
  timeout: "RoundStart";
}

export const of = (): RoundStart => ({
  timeout: "RoundStart"
});

export const handle: timeout.Handler<RoundStart> = (server, timeout, lobby) => {
  const lobbyGame = lobby.game;
  if (lobbyGame !== undefined) {
    const round = lobbyGame.round;
    if (round.stage === "Complete") {
      const czar = game.nextCzar(lobbyGame);
      const [call] = lobbyGame.decks.calls.replace(round.call);
      const slotCount = card.slotCount(call);
      const roundId = round.id + 1;
      const playersInRound = new Set(
        wu(lobbyGame.playerOrder).filter(id => id !== czar)
      );
      lobbyGame.decks.responses.discard(round.plays.flatMap(play => play.play));
      lobbyGame.round = {
        stage: "Playing",
        id: roundId,
        czar: czar,
        players: playersInRound,
        call: call,
        plays: []
      };
      const playersArray = Array.from(playersInRound);
      const basicEvent = roundStarted.of(roundId, czar, playersArray, call);
      let events: event.Targeted[];
      if (
        slotCount > 2 ||
        (slotCount === 2 &&
          lobbyGame.rules.houseRules.packingHeat !== undefined)
      ) {
        events = [
          event.target(basicEvent, (id, user) => user.role !== "Player")
        ];
        const responseDeck = lobbyGame.decks.responses;
        for (const [id, player] of lobbyGame.players) {
          const extra = responseDeck.draw(slotCount - 1);
          player.hand.push(...extra);
          events.push(
            event.targetSpecifically(
              roundStarted.of(roundId, czar, playersArray, call, extra),
              id
            )
          );
        }
      } else {
        events = [event.target(basicEvent)];
      }
      return { lobby, events };
    }
  }
  return {};
};
