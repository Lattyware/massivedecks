import * as Play from "../../games/cards/play";

/**
 * Indicates a play was liked.
 * Note this is only sent out after likes are visible (when the round is complete).
 */
export interface PlayLiked {
  event: "PlayLiked";
  id: Play.Id;
}

export const of = (id: Play.Id): PlayLiked => ({
  event: "PlayLiked",
  id,
});
