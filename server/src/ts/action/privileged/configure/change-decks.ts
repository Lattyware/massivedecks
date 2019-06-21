import { Action } from "../../../action";
import * as event from "../../../event";
import { DecksChanged } from "../../../events/lobby-event/configured/decks-changed";
import * as source from "../../../games/cards/source";
import * as sources from "../../../games/cards/sources";
import * as config from "../../../lobby/config";
import { LoadDeckSummary } from "../../../task/load-deck-summary";
import { Handler } from "../../handler";
import * as configure from "../configure";

/**
 * Make a change to the configuration of decks for the lobby.
 */
export interface ChangeDecks extends configure.Base {
  action: NameType;
  deck: source.External;
  change: config.PlayerDriven;
}

type NameType = "ChangeDecks";
const name: NameType = "ChangeDecks";

/**
 * Check if an action is an change decks action.
 * @param action The action to check.
 */
export const is = (action: Action): action is ChangeDecks =>
  action.action === name;

export const handle: Handler<ChangeDecks> = (auth, lobby, action) => {
  const config = lobby.config;
  const version = config.version + 1;
  let change: undefined | config.PlayerDriven = undefined;
  const deckSource = action.deck;
  deckSource.playCode = deckSource.playCode.toUpperCase();
  const resolver = sources.limitedResolver(deckSource);
  switch (action.change) {
    case "Add":
      if (
        config.decks.find(deck => resolver.equals(deck.source)) === undefined
      ) {
        change = "Add";
        config.decks.push({ source: deckSource });
      }
      break;
    case "Remove":
      const index = config.decks.findIndex(deck =>
        resolver.equals(deck.source)
      );
      if (index > -1) {
        change = "Remove";
        config.decks.splice(index, 1);
      }
      break;
  }
  if (change === undefined) {
    return {};
  } else {
    config.version = version;
    const decksChanged: DecksChanged = {
      event: "DecksChanged",
      version: version.toString(),
      deck: deckSource,
      change: change
    };
    return {
      lobby,
      events: [event.target(decksChanged)],
      tasks: [new LoadDeckSummary(auth.gc, deckSource)]
    };
  }
};
