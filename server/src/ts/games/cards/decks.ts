import wu from "wu";
import * as Cache from "../../cache";
import { OutOfCardsError } from "../../errors/game-state-error";
import * as Util from "../../util";
import { BaseCard } from "./card";
import * as Card from "./card";

const union = <T>(sets: Iterable<Set<T>>): Set<T> => {
  const result = new Set<T>();
  for (const set of sets) {
    for (const element of set) {
      result.add(element);
    }
  }
  return result;
};

/**
 * A deck of cards.
 */
export class Deck<C extends Card.BaseCard> {
  /**
   * The cards in the deck.
   */
  public readonly cards: C[];
  /**
   * Cards drawn from this deck that have since been discarded (used for reshuffling).
   */
  public readonly discarded: Set<C>;

  public static fromTemplates<C extends Card.BaseCard>(
    template: Iterable<Template<C>>
  ): Deck<C> {
    const deck = new Deck([], union(template));
    deck.reshuffle();
    return deck;
  }

  private constructor(cards: C[], discarded: Iterable<C>) {
    this.cards = cards;
    this.discarded = new Set(discarded);
  }

  public discard(cards: Iterable<C>): void;
  public discard(firstCard: C, ...cards: C[]): void;
  public discard(firstCard: C | Iterable<C>, ...cards: C[]): void {
    const resolvedCards: Iterable<C> = Util.isIterable(firstCard)
      ? cards
      : [firstCard, ...cards];
    for (const c of resolvedCards) {
      this.discarded.add(c);
    }
  }

  public draw(cards: number): C[] {
    const cardsLeft = this.cards.length;
    const toDraw = Math.min(cardsLeft, cards);
    const result = this.cards.splice(0, toDraw);
    if (toDraw < cards) {
      this.reshuffle();
      return [...result, ...this.draw(cards - toDraw)];
    } else {
      return result;
    }
  }

  public replace(...cards: C[]): C[] {
    this.discard(cards);
    return this.draw(cards.length);
  }

  private reshuffle(): void {
    if (this.discarded.size < 1) {
      throw new OutOfCardsError();
    }
    this.cards.push(...Util.shuffled(this.discarded));
    this.discarded.clear();
  }

  static fromJSON<C extends BaseCard>(deck: Deck<C>): Deck<C> {
    return new Deck(deck.cards, deck.discarded);
  }

  public toJSON(): object {
    return {
      cards: this.cards,
      discarded: Array.from(this.discarded)
    };
  }
}

/**
 * The two decks needed for a game.
 */
export interface Decks {
  calls: Deck<Card.Call>;
  responses: Deck<Card.PotentiallyBlankResponse>;
}

/**
 * A template for a deck.
 */
export type Template<C extends Card.BaseCard> = Set<C>;

/**
 * Templates for the two decks needed for a game.
 */
export interface Templates extends Cache.Tagged {
  calls: Template<Card.Call>;
  responses: Template<Card.PotentiallyBlankResponse>;
}

export const decks = (templates: Iterable<Templates>): Decks => ({
  calls: Deck.fromTemplates(wu(templates).map(template => template.calls)),
  responses: Deck.fromTemplates(
    wu(templates).map(template => template.responses)
  )
});
