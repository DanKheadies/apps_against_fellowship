/* eslint-disable max-len */
/**
 * Does stuff
 *
 * @param {T[]} array
 * @param {T} predicate
 * @return {boolean}
 */
export function all<T>(array: T[], predicate: (value: T) => boolean): boolean {
  for (const value of array) {
    if (!predicate(value)) {
      return false;
    }
  }
  return true;
}

/**
 * Does stuff
 *
 * @param {T[]} array
 * @param {T} predicate
 * @return {boolean}
 */
export function none<T>(array: T[], predicate: (value: T) => boolean): boolean {
  for (const value of array) {
    if (predicate(value)) {
      return false;
    }
  }
  return true;
}

/**
 * Does stuff
 *
 * @param {T[]} array
 * @param {T} predicate
 * @return {boolean}
 */
export function any<T>(array: T[], predicate: (value: T) => boolean): boolean {
  for (const value of array) {
    if (predicate(value)) {
      return true;
    }
  }
  return false;
}

/**
 * Sort an array by using an indexed map
 *
 * @param {T[]} array
 * @param {Object} indexedMap
 * @param {T} selector
 * @return {T[]}
 */
export function sortByIndexedMap<T>(
  array: T[],
  indexedMap: {[key: string]: string},
  selector: (value: T) => string
): T[] {
  return array.sort((a, b) => {
    const aEntry = Object.entries(indexedMap)
      .find(([value]) => value === selector(a));
    const bEntry = Object.entries(indexedMap)
      .find(([value]) => value === selector(b));

    if (aEntry && bEntry) {
      const aIndex = parseInt(aEntry[0]);
      const bIndex = parseInt(bEntry[0]);
      return aIndex - bIndex;
    }

    return 0;
  });
}
