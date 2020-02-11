import wu from "wu";
import * as Event from "../event";
import * as StartRevealing from "../events/game-event/start-revealing";
import * as Card from "../games/cards/card";
import * as Round from "../games/game/round";
import * as Timeout from "../timeout";
import * as Util from "../util";
import * as RoundStageTimerDone from "./round-stage-timer-done";

/**
 * Indicates that the round should start the judging phase if it is appropriate
 * to do so.
 */
export interface FinishedPlaying {
  timeout: "FinishedPlaying";
}

const isFinished = (round: Round.Playing): boolean => {
  const hasPlayed = new Set(wu(round.plays).map(play => play.playedBy));
  return Util.setEquals(round.players, hasPlayed);
};

export const of = (): FinishedPlaying => ({
  timeout: "FinishedPlaying"
});

export const ifNeeded = (playing: Round.Playing): FinishedPlaying | undefined =>
  isFinished(playing) ? of() : undefined;

export const handle: Timeout.Handler<FinishedPlaying> = (
  server,
  timeout,
  gameCode,
  lobby
) => {
  const game = lobby.game;
  if (game === undefined) {
    return {};
  }
  const round = game.round;
  if (round.stage !== "Playing" || !isFinished(round)) {
    return {};
  }

  // We discard the plays first so if the deck runs out, all the cards get
  // rotated in.
  const responses = game.decks.responses;
  for (const play of round.plays) {
    responses.discard(play.play);
  }

  const slotCount = Card.slotCount(round.call);
  const extraCards =
    slotCount > 2 ||
    (slotCount === 2 && game.rules.houseRules.packingHeat !== undefined)
      ? slotCount - 1
      : 0;
  const newCardsByPlayer = new Map();
  for (const play of round.plays) {
    const idSet = new Set(play.play.map(c => c.id));
    const player = game.players[play.playedBy];
    if (player !== undefined) {
      player.hand = player.hand.filter(card => !idSet.has(card.id));
      const toDraw = play.play.length - extraCards;
      const drawn = responses.draw(toDraw);
      newCardsByPlayer.set(play.playedBy, { drawn });
      player.hand.push(...drawn);
    }
  }

  game.round = round.advance();

  const playsToBeRevealed = Array.from(
    wu(game.round.plays).map(play => play.id)
  );
  const events = [
    Event.additionally(StartRevealing.of(playsToBeRevealed), newCardsByPlayer)
  ];

  const timeouts = [];
  const timer = RoundStageTimerDone.ifEnabled(
    game.round,
    game.rules.timeLimits
  );
  if (timer !== undefined) {
    timeouts.push(timer);
  }

  return {
    lobby,
    events: events,
    timeouts: timeouts
  };
};
