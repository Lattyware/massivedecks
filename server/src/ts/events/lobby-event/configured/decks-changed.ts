import * as source from "../../../games/cards/source";
import * as config from "../../../lobby/config";
import * as configured from "../configured";

/**
 * A change was made to the configuration of decks for the lobby.
 */
export interface DecksChanged extends configured.Base {
  event: "DecksChanged";
  deck: source.External;
  change: config.DeckChange;
}

export const of = (
  deck: source.External,
  change: config.DeckChange,
  version: config.Version
): DecksChanged => ({
  event: "DecksChanged",
  deck,
  change,
  version: version.toString()
});
