import { IncorrectUserRoleError } from "../../../errors/action-execution-error";
import { InvalidActionError } from "../../../errors/validation";
import * as Event from "../../../event";
import * as PlaySubmitted from "../../../events/game-event/play-submitted";
import * as Card from "../../../games/cards/card";
import * as Play from "../../../games/cards/play";
import * as Round from "../../../games/game/round";
import * as Lobby from "../../../lobby";
import * as FinishedPlaying from "../../../timeout/finished-playing";
import * as Actions from "../../actions";
import * as Handler from "../../handler";
import { Player } from "../player";

/**
 * A player plays a white card into a round.
 */
export interface Submit {
  action: "Submit";
  play: (Card.Id | FilledBlankCard)[];
}

export interface FilledBlankCard {
  id: Card.Id;
  text: string;
}

const isFilledBlankCard = (
  card: Card.Id | FilledBlankCard
): card is FilledBlankCard => typeof card !== "string";

class SubmitActions extends Actions.Implementation<
  Player,
  Submit,
  "Submit",
  Lobby.WithActiveGame
> {
  protected readonly name = "Submit";

  protected handle: Handler.Custom<Submit, Lobby.WithActiveGame> = (
    auth,
    lobby,
    action,
    server
  ) => {
    const lobbyRound = lobby.game.round;
    if (lobbyRound.verifyStage<Round.Playing>(action, "Playing")) {
      const playId = Play.id();
      const plays = lobbyRound.plays;
      if (plays.find(play => play.playedBy === auth.uid)) {
        throw new InvalidActionError("Already played into round.");
      }
      const playLength = action.play.length;
      const slotCount = Card.slotCount(lobbyRound.call);
      if (playLength !== slotCount) {
        throw new InvalidActionError(
          "The play must have the same number of responses as the call " +
            `has slots (expected ${slotCount}, got ${playLength}).`
        );
      }
      const player = lobby.game.players.get(auth.uid);
      if (player === undefined) {
        throw new IncorrectUserRoleError(action, "Spectator", "Player");
      }
      const cards = new Set(action.play);
      const extractedPlay: Play.Play = [];
      for (const playedCard of cards) {
        const id = isFilledBlankCard(playedCard) ? playedCard.id : playedCard;
        const played = player.hand.find(c => c.id === id);
        if (played === undefined) {
          throw new InvalidActionError(
            "The given card doesn't exist or isn't in the player's hand."
          );
        }
        if (Card.isBlankResponse(played)) {
          if (isFilledBlankCard(playedCard)) {
            extractedPlay.push({
              text: playedCard.text,
              ...played
            });
          } else {
            throw new InvalidActionError(
              "The given card is blank, but the play didn't provide the value."
            );
          }
        } else {
          if (isFilledBlankCard(playedCard)) {
            throw new InvalidActionError(
              "The given card is not blank, but the play provided a value."
            );
          } else {
            extractedPlay.push(played);
          }
        }
      }
      plays.push({
        id: playId,
        play: extractedPlay,
        playedBy: auth.uid,
        revealed: false,
        likes: new Set()
      });
      const events = [Event.targetAll(PlaySubmitted.of(auth.uid))];
      const timeouts = [];
      const timeout = FinishedPlaying.ifNeeded(lobbyRound);
      if (timeout !== undefined) {
        timeouts.push({
          timeout: timeout,
          after: server.config.timeouts.finishedPlayingDelay
        });
      }
      return { lobby, events, timeouts };
    } else {
      return {};
    }
  };
}

export const actions = new SubmitActions();
