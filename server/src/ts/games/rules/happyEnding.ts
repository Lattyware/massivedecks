import * as Card from "../cards/card";

/**
 * Configuration for the "Happy Ending" house rule.
 * When the game ends, the final round is a 'Make a Haiku' black card.
 */
export interface HappyEnding {
  inFinalRound?: boolean;
}

export const happyEndingCall: Card.Call = {
  id: Card.id(),
  parts: [
    ["Make a haiku."],
    [
      {
        transform: "Capitalize",
      },
      ",",
    ],
    [
      {
        transform: "Capitalize",
      },
      ",",
    ],
    [
      {
        transform: "Capitalize",
      },
      ".",
    ],
  ],
  source: { source: "Generated", by: "HappyEndingRule" },
};
