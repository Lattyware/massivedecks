import * as uuid from "uuid";
import wu from "wu";
import { Source } from "./source";
import { Custom } from "./sources/custom";

/**
 * A game card.
 */
export type Card = Call | Response;

/**
 * A call for plays. Some text with blank slots to be filled with responses.
 */
export interface Call extends BaseCard {
  /** The text and slots on the call.*/
  parts: Part[][];
}

/**
 * A response (some text) played into slots.
 */
export interface Response extends BaseCard {
  /** The text on the response. If this is undefined, the card is a blank
   * card. */
  text: string;
}

/**
 * A custom response is special in that it is mutable by the player holding it.
 */
export interface CustomResponse extends Response {
  source: Custom;
}

/**
 * If the response is a custom one, and therefore mutable.
 */
export const isCustomResponse = (
  response: Response
): response is CustomResponse => response.source.source == "Custom";

/** A unique id for an instance of a card.*/
export type Id = string;

/** Values shared by all cards.*/
export interface BaseCard {
  /** A unique id for a card.*/
  id: Id;
  /** Where the card came from.*/
  source: Source;
}

export type Style = "Em" | "Strong";

/** An empty slot for responses to be played into.*/
export interface Slot {
  index?: number;
  /**
   * Defines a transformation over the content the slot is filled with.
   */
  transform?: "UpperCase" | "Capitalize";
  style?: Style;
}

export interface Styled {
  text: string;
  style?: Style;
}

export const isSlot = (part: Part): part is Slot =>
  typeof part !== "string" && !part.hasOwnProperty("text");

export const isStyled = (part: Part): part is Styled =>
  typeof part !== "string" && part.hasOwnProperty("text");

/** Either text or a slot.*/
export type Part = string | Styled | Slot;

/**
 * Create a new user id.
 */
export const id: () => Id = uuid.v4;

/**
 * If the given card is a call.
 */
export const isCall = (card: Card): card is Call =>
  (card as Call).parts !== undefined;

/**
 * If the given card is a response.
 */
export const isResponse = (card: Card): card is Response =>
  (card as Response).text !== undefined;

/**
 * The number of slots the given call.
 */
export const slotCount = (call: Call | Part[][]): number => {
  let next = 0;
  const indices = wu(
    call.hasOwnProperty("parts") ? (call as Call).parts : (call as Part[][])
  )
    .flatten(true)
    .concatMap((part) =>
      isSlot(part) ? [part.index !== undefined ? part.index : next++] : []
    );
  return new Set(indices).size;
};
