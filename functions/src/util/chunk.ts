/* eslint-disable max-len */

/**
 * Chunk an array into an array of arrays as defined by the input size
 *
 * @param {T[]} array the array to chunk
 * @param {number} size the size of each chunk
 * @return {T[][]}
 */
export function chunkArray<T>(array: T[], size: number): T[][] {
  const result: T[][] = [];
  for (let i = 0; i < array.length; i += size) {
    const chunk = array.slice(i, i + size);
    result.push(chunk);
  }
  return result;
}
