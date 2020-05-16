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
import * as Util from "../../../util";

/**
 * A player plays a white card into a round.
 */
export interface Submit {
  action: "Submit";
  play: Card.Id[];
}

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
      if (plays.find((play) => play.playedBy === auth.uid)) {
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
      const player = lobby.game.players[auth.uid];
      if (player === undefined) {
        throw new IncorrectUserRoleError(action, "Spectator", "Player");
      }
      const extractedPlay: Play.Play = [];
      for (const playedCard of action.play) {
        const played = player.hand.find((c) => c.id === playedCard);
        if (played === undefined) {
          throw new InvalidActionError(
            "The given card doesn't exist or isn't in the player's hand."
          );
        }
        extractedPlay.push(played);
      }
      plays.push({
        id: playId,
        play: extractedPlay,
        playedBy: auth.uid,
        revealed: false,
        likes: [],
      });
      const events = [Event.targetAll(PlaySubmitted.of(auth.uid))];
      const timeouts = Util.asOptionalIterable(
        FinishedPlaying.ifNeeded(lobby.game.rules, lobbyRound)
      );
      return { lobby, events, timeouts };
    } else {
      return {};
    }
  };
}

export const actions = new SubmitActions();
