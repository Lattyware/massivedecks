/**
 * The base for JSON payload for errors.
 */
export interface Details {
  error: string;
}

/**
 * An error specific to Massive Decks. These can be sent as JSON loads or HTTP
 * responses.
 */
export abstract class MassiveDecksError<T extends Details> extends Error {
  public abstract readonly status: number;
  public abstract details(): T;
}
