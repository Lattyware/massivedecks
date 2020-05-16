/**
 * Check if the given value is an iterable one.
 */
export const isIterable = <T extends object>(
  object: T | Iterable<T>
): object is Iterable<T> =>
  object !== null &&
  typeof (object as Iterable<T>)[Symbol.iterator] === "function";

const isSingleArgument = <A, B, C>(
  f: ((a: A, b: B) => C) | ((b: B) => C)
): f is (b: B) => C => f.length === 1;

/**
 * Take an object and apply the given function to each value, producing a new
 * object.
 */
export function mapObjectValues<O extends { [key: string]: V }, V, U>(
  obj: O,
  f: ((key: string, value: V) => U) | ((value: V) => U)
): { [P in keyof O]: U } {
  const newObj: { [key: string]: U } = {};
  for (const [key, value] of Object.entries(obj)) {
    newObj[key] = isSingleArgument(f) ? f(value) : f(key, value);
  }
  return newObj as { [P in keyof O]: U };
}

/**
 * Create an object from the given entries.
 */
export function entriesToObject<T>(
  entries: Iterable<[string, T]>
): { [key: string]: T } {
  const obj: { [key: string]: T } = {};
  for (const [key, value] of entries) {
    obj[key] = value;
  }
  return obj;
}

/**
 * Create an object from the given map.
 */
export const mapToObject = <T>(map: Map<string, T>): { [key: string]: T } =>
  entriesToObject(map);

/**
 * Count the number of elements in the given iterable that conform to the given
 * predicates. Returns the counts in an object matching the shape of the
 * predicates.
 * @param iterable The iterable to count the values of.
 * @param predicates The predicates to apply to each value to check if it should
 *                   be counted.
 */
export function counts<T, U>(
  iterable: Iterable<T>,
  predicates: { [P in keyof U]: (value: T) => boolean }
): { [P in keyof U]: number } {
  const keys = Object.keys(predicates) as (keyof U)[];
  const amounts = mapObjectValues(predicates, () => 0);
  for (const value of iterable) {
    for (const key of keys) {
      if (predicates[key](value)) {
        amounts[key] += 1;
      }
    }
  }
  return amounts;
}

/**
 * This will only be valid when the given outcome is impossible. Useful for
 * exhaustiveness checks.
 * @param value The impossible value.
 */
export function assertNever(value: never): never {
  throw new Error(`Unexpected value: ${JSON.stringify(value)}.`);
}

/**
 * Find the first value that satisfies the given predicate in the given iterable,
 * allowing for type assertion.
 * @param iterable The iterable.
 * @param predicate THe predicate.
 */
export function findIs<T, U extends T>(
  iterable: Iterable<T>,
  predicate: (item: T) => item is U
): U | undefined {
  for (const item of iterable) {
    if (predicate(item)) {
      return item;
    }
  }
  return undefined;
}

/**
 * Shuffle the given array in-place.
 * @param items The array.
 */
export function shuffle<T>(items: T[]): void {
  for (let index = items.length - 1; index > 0; index -= 1) {
    const random = Math.floor(Math.random() * (index + 1));
    [items[index], items[random]] = [items[random], items[index]];
  }
}

/**
 * Return a shuffled array of the given elements.
 * @param items The items to shuffle.
 */
export function shuffled<T>(items: Iterable<T>): T[] {
  const result = Array.from(items);
  shuffle(result);
  return result;
}

/**
 * If both sets contain the same (and only the same) values.
 */
export function setEquals<T>(a: Set<T>, b: Set<T>): boolean {
  if (a.size !== b.size) {
    return false;
  } else {
    for (const value of a) {
      if (!b.has(value)) {
        return false;
      }
    }
    return true;
  }
}

/**
 * Return an item that may be undefined as either an iterable of nothing or an iterable of just that item.
 */
export function* asIterable<T>(
  maybeItem: T | undefined
): Iterable<T> | undefined {
  if (maybeItem !== undefined) {
    yield maybeItem;
  }
}

/**
 * Return an item that may be undefined as either a undefined or an iterable of just that item.
 */
export function asOptionalIterable<T>(
  maybeItem: T | undefined
): Iterable<T> | undefined {
  if (maybeItem === undefined) {
    return undefined;
  } else {
    return asIterable(maybeItem);
  }
}
