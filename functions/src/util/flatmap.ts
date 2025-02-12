/* eslint-disable max-len */
/**
 * Perform a 'flatMap' operation since we can't apparently use 'es2019' in Firebase Functions
 * @param {T[]} array the array of items we want to flat map
 * @param {R[]} selector the selector to pull the sub-array of items out of each item to flatten
 * @return {R[]}
 */
export function flatMap<T, R>(array: T[], selector: (item: T) => R[]): R[] {
  return Array.prototype.concat(...array.map(selector));
}

/**
 * Flatten an array of arrays into a single array
 * @param {T[][]} array
 * @return {T[]}
 */
export function flatten<T>(array: T[][]): T[] {
  return Array.prototype.concat(...array);
}
