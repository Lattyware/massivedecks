import wu from "wu";
import * as event from "../event";
import * as startRevealing from "../events/game-event/start-revealing";
import * as card from "../games/cards/card";
import * as round from "../games/game/round";
import * as timeout from "../timeout";
import * as util from "../util";

/**
 * Indicates that the round should start the judging phase if it is appropriate
 * to do so.
 */
export interface FinishedPlaying {
  timeout: "FinishedPlaying";
}

const isFinished = (round: round.Playing): boolean => {
  const hasPlayed = new Set(wu(round.plays).map(play => play.playedBy));
  return util.setEquals(round.players, hasPlayed);
};

export const of = (): FinishedPlaying => ({
  timeout: "FinishedPlaying"
});

export const ifNeeded = (playing: round.Playing): FinishedPlaying | undefined =>
  isFinished(playing) ? of() : undefined;

export const handle: timeout.Handler<FinishedPlaying> = (
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
  const plays = round.plays;
  if (round.stage !== "Playing" || !isFinished(round)) {
    return {};
  }

  // We discard the plays first so if the deck runs out, all the cards get
  // rotated in.
  const responses = game.decks.responses;
  for (const play of round.plays) {
    responses.discard(play.play);
  }

  const slotCount = card.slotCount(round.call);
  let extraCards =
    slotCount > 2 ||
    (slotCount === 2 && game.rules.houseRules.packingHeat !== undefined)
      ? slotCount - 1
      : 0;
  const newCardsByPlayer = new Map();
  for (const play of round.plays) {
    const idSet = new Set(play.play.map(c => c.id));
    const player = game.players.get(play.playedBy);
    if (player !== undefined) {
      player.hand = player.hand.filter(card => !idSet.has(card.id));
      const toDraw = play.play.length - extraCards;
      const drawn = responses.draw(toDraw);
      newCardsByPlayer.set(play.playedBy, { drawn });
      player.hand.push(...drawn);
    }
  }

  const playsToBeRevealed = Array.from(wu(plays).map(play => play.id));
  const events = [
    event.additionally(startRevealing.of(playsToBeRevealed), newCardsByPlayer)
  ];

  game.round = round.advance();
  return {
    lobby,
    events: events
  };
};
